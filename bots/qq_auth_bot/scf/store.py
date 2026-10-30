#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""发码账本 —— 存到腾讯云对象存储（COS）。

为什么不能继续用 SQLite
-----------------------
云函数实例随时会被回收，写进本地文件的账本下一次调用就没了。表现是
「同一个玩家反复领，每次拿到不同的码，而且能无限领」——数据悄悄损坏，
不会报错，最难发现。

所以账本必须放到函数之外。这里用 COS 上的一个 JSON 对象：

    {"entries": {"<机器码>": {"uid": ..., "id": ..., "code": ..., "ts": ...}}}

以**机器码**为主键，和 SQLite 版保持同一个语义（`tools/qq_auth.py` 的
`Ledger` 就是这么设计的：一台机器只会有一个有效码）。

免依赖说明
----------
不用 `cos-python-sdk-v5`，因为它依赖 `crcmod`（C 扩展），跨平台打包很容易
翻车。COS 的签名就是 HMAC-SHA1，标准库 `hmac` 直接能算，所以这里自己实现
一份，整个函数真正零第三方依赖。
"""

import hashlib
import hmac
import json
import os
import threading
import time
import urllib.error
import urllib.parse
import urllib.request


def _quote(value):
    """COS 要求 RFC 3986 编码，Python 默认的 quote 会保留 '/'，必须改。"""
    return urllib.parse.quote(str(value), safe="-_.~")


def _hmac_sha1_hex(key, message):
    if isinstance(key, str):
        key = key.encode("utf-8")
    if isinstance(message, str):
        message = message.encode("utf-8")
    return hmac.new(key, message, hashlib.sha1).hexdigest()


def _sha1_hex(text):
    return hashlib.sha1(text.encode("utf-8")).hexdigest()


def cos_authorization(secret_id, secret_key, method, path, host,
                      params=None, expires=600):
    """生成 COS 的 Authorization 头。签名算法见官方《请求签名》。"""
    params = params or {}
    now = int(time.time())
    key_time = "%d;%d" % (now, now + expires)

    url_param_list = ";".join(sorted(k.lower() for k in params))
    header_list = "host"
    http_headers = "host=%s" % _quote(host)
    http_params = "&".join(
        "%s=%s" % (k.lower(), _quote(params[k]))
        for k in sorted(params, key=lambda x: x.lower())
    )

    http_string = "%s\n%s\n%s\n%s\n" % (method.lower(), path, http_params, http_headers)
    string_to_sign = "sha1\n%s\n%s\n" % (key_time, _sha1_hex(http_string))
    sign_key = _hmac_sha1_hex(secret_key, key_time)
    signature = _hmac_sha1_hex(sign_key, string_to_sign)

    return (
        "q-sign-algorithm=sha1&q-ak=%s&q-sign-time=%s&q-key-time=%s"
        "&q-header-list=%s&q-url-param-list=%s&q-signature=%s"
        % (secret_id, key_time, key_time, header_list, url_param_list, signature)
    )


class CosClient(object):
    """只用 GetObject / PutObject 两个接口，够账本用了。"""

    def __init__(self, secret_id, secret_key, region, bucket, timeout=5):
        self.secret_id = secret_id
        self.secret_key = secret_key
        self.region = region
        self.bucket = bucket
        self.timeout = timeout
        self.host = "%s.cos.%s.myqcloud.com" % (bucket, region)

    def _request(self, method, key, body=None):
        path = "/" + key.lstrip("/")
        url = "https://%s%s" % (self.host, path)
        headers = {
            "Host": self.host,
            "Authorization": cos_authorization(
                self.secret_id, self.secret_key, method, path, self.host
            ),
        }
        if body is not None:
            headers["Content-Type"] = "application/json; charset=utf-8"
        req = urllib.request.Request(url, data=body, method=method, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                return resp.status, resp.read()
        except urllib.error.HTTPError as exc:
            return exc.code, exc.read()

    def get_json(self, key):
        """返回 (数据, 是否存在)。"""
        status, raw = self._request("GET", key)
        if status == 404:
            return None, False
        if status >= 400:
            raise RuntimeError("COS 读取失败 %s：%s"
                               % (status, raw[:200].decode("utf-8", "replace")))
        return json.loads(raw.decode("utf-8")), True

    def put_json(self, key, data):
        body = json.dumps(data, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        status, raw = self._request("PUT", key, body)
        if status >= 400:
            raise RuntimeError("COS 写入失败 %s：%s"
                               % (status, raw[:200].decode("utf-8", "replace")))
        return True


# ---------------------------------------------------------------- 存储后端

class MemoryStore(object):
    """进程内存储，只用于本地调试和自检。"""

    def __init__(self):
        self.data = {}

    def load(self):
        return json.loads(json.dumps(self.data)) if self.data else {"entries": {}}

    def save(self, data):
        self.data = json.loads(json.dumps(data))


class FileStore(object):
    """本地文件，用于「不连云也能把整条链路跑通」的调试。"""

    def __init__(self, path):
        self.path = path

    def load(self):
        if not os.path.exists(self.path):
            return {"entries": {}}
        with open(self.path, "r", encoding="utf-8") as fh:
            return json.load(fh)

    def save(self, data):
        tmp = self.path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(data, fh, ensure_ascii=False, indent=1)
        os.replace(tmp, self.path)


class CosStore(object):
    def __init__(self, client, key):
        self.client = client
        self.key = key

    def load(self):
        data, _exists = self.client.get_json(self.key)
        if not data:
            return {"entries": {}}
        if "entries" not in data or not isinstance(data["entries"], dict):
            raise RuntimeError("账本格式损坏（缺 entries）：cos://%s" % self.key)
        return data

    def save(self, data):
        self.client.put_json(self.key, data)


# ---------------------------------------------------------------- 账本

class Ledger(object):
    """接口和 `tools/qq_auth.py` 里的 SQLite 账本保持一致。

    这样 `qq_auth.issue_for()` 可以原样复用——密码学和发码规则只有一份
    源码，不会出现「机器人按旧规则发、游戏端按新规则验」的错位。
    """

    _lock = threading.Lock()

    def __init__(self, store, autosave=True):
        self.store = store
        self.autosave = autosave
        with self._lock:
            self._data = store.load()
        # 老账本只有 entries，这两个字段是后加的，必须补默认值，
        # 否则第一次调用 is_admin() 会 KeyError。
        if not isinstance(self._data.get("admins"), list):
            self._data["admins"] = []
        if not isinstance(self._data.get("audit"), list):
            self._data["audit"] = []
        self._dirty = False

    # ── 管理员 / 审计 ──
    def admins(self):
        return [a["uid"] for a in self._data["admins"]]

    def is_admin(self, uid):
        return str(uid) in self.admins()

    def admin_add(self, uid, label=""):
        """加入管理员白名单。返回 True 表示新增。"""
        uid = str(uid or "").strip()
        if not uid or self.is_admin(uid):
            return False
        self._data["admins"].append({
            "uid": uid,
            "label": str(label or ""),
            "ts": int(time.time()),
        })
        self._dirty = True
        return True

    def audit_append(self, action, actor, target, detail=""):
        """留痕。只保留最近 200 条，别让账本无限膨胀。"""
        self._data["audit"].append({
            "ts": int(time.time()),
            "action": str(action),
            "actor": str(actor),
            "target": str(target),
            "detail": str(detail)[:200],
        })
        if len(self._data["audit"]) > 200:
            del self._data["audit"][:-200]
        self._dirty = True

    def audit_tail(self, n=10):
        return self._data["audit"][-int(n):]

    # ── 读 ──
    def get_by_hwid(self, hwid):
        row = self._data["entries"].get(_norm(hwid))
        if not row:
            return None
        # 返回顺序对齐 SQLite：(hwid, uid, code_id, code, ts)
        return (row["hwid"], row["uid"], row["id"], row["code"], row["ts"])

    def count_by_uid(self, uid):
        return sum(1 for r in self._data["entries"].values() if r["uid"] == str(uid))

    def get_by_uid(self, uid):
        rows = [r for r in self._data["entries"].values() if r["uid"] == str(uid)]
        rows.sort(key=lambda r: r["ts"])
        return [(r["hwid"], r["uid"], r["id"], r["code"], r["ts"]) for r in rows]

    def used_ids(self):
        return set(r["id"] for r in self._data["entries"].values())

    def count(self):
        return len(self._data["entries"])

    def all(self):
        rows = list(self._data["entries"].values())
        rows.sort(key=lambda r: r["ts"])
        return [(r["hwid"], r["uid"], r["id"], r["code"], r["ts"]) for r in rows]

    def get_by_code_id(self, code_id):
        """按码 ID 反查。

        管理员解绑时，玩家报过来的可能是授权码而不是识别码，
        所以两种都要认。
        """
        cid = str(code_id or "").strip().upper()
        if not cid:
            return None
        for r in self._data["entries"].values():
            if str(r["id"]).upper() == cid:
                return (r["hwid"], r["uid"], r["id"], r["code"], r["ts"])
        return None

    # ── 写 ──
    def put(self, uid, hwid, code_id, code):
        hwid = _norm(hwid)
        self._data["entries"][hwid] = {
            "hwid": hwid,
            "uid": str(uid),
            "id": code_id,
            "code": code,
            "ts": int(time.time()),
        }
        self._dirty = True

    def drop_hwid(self, hwid):
        hwid = _norm(hwid)
        if hwid in self._data["entries"]:
            del self._data["entries"][hwid]
            self._dirty = True
            return 1
        return 0

    def drop_uid(self, uid):
        victims = [h for h, r in self._data["entries"].items() if r["uid"] == str(uid)]
        for hwid in victims:
            del self._data["entries"][hwid]
        if victims:
            self._dirty = True
        return len(victims)

    def flush(self):
        if not self._dirty:
            return False
        with self._lock:
            self.store.save(self._data)
        self._dirty = False
        return True

    def close(self):
        if self.autosave:
            self.flush()


def _norm(hwid):
    return str(hwid or "").strip().upper()


def build_ledger(store, autosave=True):
    return Ledger(store, autosave=autosave)


def ledger_from_env(autosave=True):
    """按环境变量决定用 COS 还是本地文件。

    COS_* 齐了就用 COS；否则退回本地文件（本地联调用，云上千万别这样）。
    """
    sid = os.environ.get("COS_SECRET_ID", "").strip()
    skey = os.environ.get("COS_SECRET_KEY", "").strip()
    region = os.environ.get("COS_REGION", "").strip()
    bucket = os.environ.get("COS_BUCKET", "").strip()
    key = os.environ.get("COS_KEY", "qqauth/ledger.json").strip() or "qqauth/ledger.json"

    if sid and skey and region and bucket:
        return Ledger(CosStore(CosClient(sid, skey, region, bucket), key), autosave)

    path = os.environ.get("AUTH_LEDGER_FILE", "").strip()
    if not path:
        path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_ledger_debug.json")
    return Ledger(FileStore(path), autosave)


# ---------------------------------------------------------------- 自检

def selftest():
    """账本逻辑自检：不需要网络。"""
    import tempfile

    ok = True

    def check(cond, good, bad):
        nonlocal ok
        if cond:
            print("  ✓ %s" % good)
        else:
            ok = False
            print("  ✗ %s" % bad)

    store = MemoryStore()
    led = Ledger(store)
    check(led.count() == 0, "空账本", "空账本计数不为 0")
    check(led.get_by_hwid("1a2b3c4d") is None, "查不到不存在的机器", "幽灵记录")

    led.put("uid-1", "1a2b3c4d", "ABCD1234", "FVM4-ABCD1234-1A2B3C4D-0011223344")
    check(led.count_by_uid("uid-1") == 1, "按 uid 计数", "按 uid 计数错误")
    row = led.get_by_hwid("1A2B3C4D")
    check(row is not None and row[3].startswith("FVM4-"), "机器码大小写归一",
          "机器码没有归一化")
    check(led.used_ids() == {"ABCD1234"}, "已用 ID 集合", "已用 ID 集合错误")
    led.flush()

    # 换一个 Ledger 实例读同一份存储 → 模拟函数冷启动
    led2 = Ledger(store)
    check(led2.count() == 1, "跨实例持久化（模拟冷启动重读）", "持久化失败")
    check(led2.get_by_hwid("1A2B3C4D")[2] == "ABCD1234", "重读后码 ID 一致",
          "重读后码 ID 不一致")

    # 解绑
    check(led2.drop_uid("uid-1") == 1, "按 uid 解绑", "按 uid 解绑失败")
    led2.flush()
    led3 = Ledger(store)
    check(led3.count() == 0, "解绑持久化", "解绑没有落盘")

    # 文件后端
    tmpdir = tempfile.mkdtemp()
    path = os.path.join(tmpdir, "ledger.json")
    fstore = FileStore(path)
    f1 = Ledger(fstore)
    f1.put("u", "AABBCCDD", "ZZZZ9999", "FVM4-ZZZZ9999-AABBCCDD-0000000000")
    f1.close()
    f2 = Ledger(FileStore(path))
    check(f2.count() == 1 and os.path.exists(path), "文件后端落盘",
          "文件后端没有写文件")

    # 损坏的账本要报错，不能静默当成空账本
    class _BadClient(object):
        def get_json(self, key):
            return {"wrong": 1}, True

        def put_json(self, key, data):
            return True

    try:
        CosStore(_BadClient(), "k").load()
        check(False, "", "损坏的账本没有报错（会静默丢掉所有发放记录）")
    except RuntimeError:
        check(True, "损坏账本会报错而不是静默清空", "")

    return ok


if __name__ == "__main__":
    import sys

    print("账本自检：")
    sys.exit(0 if selftest() else 1)
