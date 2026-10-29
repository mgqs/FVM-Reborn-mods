#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FVM 授权码签发工具（离线 · 码池 + 机器指纹绑定）

码格式：FVM4-<码ID>-<机器码>-<签名>
    码ID   = tools/codes_pool.txt 里你预先准备的那批码，机器人发放时挑一个
    机器码 = 玩家机器指纹的 md5 前 8 位（游戏内「复制本机识别码」得到）
    签名   = md5("FVM4|码ID|机器码|SECRET") 前 10 位大写

关键设计：码里绑了机器码，所以**别人拿到你的码也用不了**——
他的机器算出的指纹不同，验签直接失败。这是纯离线条件下唯一
能实现「一码一机、用后别人不能再用」的办法（详见文档 12 章）。

常用命令：
    python tools/qq_auth.py poolgen 500          生成码池
    python tools/qq_auth.py pool                查看池子余量
    python tools/qq_auth.py issue <uid> <机器码>  发放
    python tools/qq_auth.py ledger              查看发放记录
    python tools/qq_auth.py revoke <机器码>      作废某台机器的码
    python tools/qq_auth.py revoke --uid <账号>  解绑该账号名下所有机器
    python tools/qq_auth.py verify <授权码>      验签
    python tools/qq_auth.py gml                 生成要贴进 GML 的宏
    python tools/qq_auth.py selftest
"""

import hashlib
import os
import random
import sqlite3
import sys
import time

# ⚠️ 密钥来源优先级：
#    1. tools/auth_secret.txt（已在 .gitignore，推荐——公开仓库里不能有真值）
#    2. 下面的 SECRET_FALLBACK 占位符
# 改动密钥 = 所有已发出的码同时失效。用 `gml` 子命令生成 GML 宏，别手抄。
SECRET_FALLBACK = "CHANGE_ME_TO_A_LONG_RANDOM_STRING_2026"

FORMAT = "FVM4"
SIG_LEN = 10
ID_LEN = 8
# 去掉 0/O/1/I 这些玩家容易看错的字符
ID_CHARS = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
ID_MIN, ID_MAX = 4, 20

# 机器码是十六进制 md5 片段，**必须保留 0 和 1**
HWID_LEN = 8
HWID_CHARS = "0123456789ABCDEF"

# 一个 QQ / openid 最多绑几台机器（防「一个号反复换识别码刷码」）
# 默认 2：够「台式 + 笔记本」两台日常使用，再多基本就是刷码了。
# 临时放宽不用改代码：set MAX_DEVICES=3（机器人端和 CLI 一起生效）
try:
    MAX_DEVICES_PER_UID = int(os.environ.get("MAX_DEVICES", "") or 2)
except ValueError:
    MAX_DEVICES_PER_UID = 2
if MAX_DEVICES_PER_UID < 1:
    MAX_DEVICES_PER_UID = 1

HERE = os.path.dirname(os.path.abspath(__file__))
POOL_PATH = os.path.join(HERE, "codes_pool.txt")
DB_PATH = os.path.join(HERE, "qq_auth.db")
SECRET_PATH = os.path.join(HERE, "auth_secret.txt")


def _load_secret():
    if os.path.exists(SECRET_PATH):
        with open(SECRET_PATH, "r", encoding="utf-8") as fh:
            value = fh.read().strip()
        if len(value) >= 16:
            return value
        print("⚠️  %s 太短（至少 16 位），改用占位符" % SECRET_PATH, file=sys.stderr)
    return SECRET_FALLBACK


SECRET = _load_secret()


# ---------------------------------------------------------------- 签名 / 组码

def norm_hwid(hwid):
    """把玩家粘贴的机器码洗成 8 位大写十六进制。洗不出来返回空串。"""
    out = []
    for ch in str(hwid or "").upper():
        if ch in HWID_CHARS:
            out.append(ch)
    value = "".join(out)
    if len(value) < HWID_LEN:
        return ""
    return value[:HWID_LEN]


def hwid_valid(hwid):
    return bool(hwid) and len(hwid) == HWID_LEN and all(c in HWID_CHARS for c in hwid)


def sign(code_id, hwid):
    raw = "%s|%s|%s|%s" % (FORMAT, code_id, hwid, SECRET)
    return hashlib.md5(raw.encode("utf-8")).hexdigest().upper()[:SIG_LEN]


def make_code(code_id, hwid):
    hwid = norm_hwid(hwid)
    if not hwid_valid(hwid):
        raise ValueError("机器码不合法：%r（应为 8 位十六进制）" % hwid)
    return "%s-%s-%s-%s" % (FORMAT, code_id, hwid, sign(code_id, hwid))


def id_valid(code_id):
    if not (ID_MIN <= len(code_id) <= ID_MAX):
        return False
    for ch in code_id:
        if ch not in ID_CHARS:
            return False
    return True


def parse_code(code):
    """返回 (码ID, 机器码, 签名)。格式不合法抛 ValueError。"""
    parts = str(code or "").strip().upper().split("-")
    if len(parts) != 4:
        raise ValueError("格式错误，应为 FVM4-XXXXXXXX-XXXXXXXX-XXXXXXXXXX")
    if parts[0] != FORMAT:
        raise ValueError("前缀不是 %s" % FORMAT)
    if not id_valid(parts[1]):
        raise ValueError("码 ID 段不合法")
    hwid = norm_hwid(parts[2])
    if not hwid_valid(hwid):
        raise ValueError("机器码段不合法")
    return parts[1], hwid, parts[3]


def verify(code):
    """返回 (是否有效, 码ID, 机器码)。不查池子，只看签名。"""
    try:
        code_id, hwid, sig = parse_code(code)
    except ValueError:
        return False, "", ""
    return sign(code_id, hwid) == sig, code_id, hwid


# ---------------------------------------------------------------- 池子

def load_pool():
    if not os.path.exists(POOL_PATH):
        return []
    out = []
    with open(POOL_PATH, "r", encoding="utf-8") as fh:
        for line in fh:
            value = line.strip().upper()
            if value and not value.startswith("#"):
                out.append(value)
    return out


def save_pool(ids):
    with open(POOL_PATH, "w", encoding="utf-8") as fh:
        fh.write("# 授权码池：一行一个，机器人按顺序发。\n")
        fh.write("# 字符集限 %s（去掉了易混淆的 0/O/1/I）\n" % ID_CHARS)
        for value in ids:
            fh.write(value + "\n")


def gen_ids(count, existing):
    existing = set(existing or [])
    result = []
    while len(result) < count:
        value = "".join(random.choice(ID_CHARS) for _ in range(ID_LEN))
        if value in existing or value in result:
            continue
        result.append(value)
    return result


# ---------------------------------------------------------------- 账本

class Ledger(object):
    """账本以**机器码**为主键。

    「一个码只能在一台机器上用」是这套方案的核心约束，
    而机器码是唯一能同时被游戏端和机器人端算出的因子
    （游戏端拿不到 openid，机器人端拿不到硬件信息），
    所以它必须当主键：同一台机器只会有一个有效码。
    """

    def __init__(self, path):
        self.path = path
        self._conn = sqlite3.connect(path)
        self._ensure_schema()

    def _ensure_schema(self):
        cols = [r[1] for r in self._conn.execute("PRAGMA table_info(issued)").fetchall()]
        if cols and "hwid" not in cols:
            # 旧版（FVM3，只按 uid 记账）自动归档，不删数据
            backup = "issued_%s" % time.strftime("%Y%m%d%H%M%S")
            self._conn.execute("ALTER TABLE issued RENAME TO %s" % backup)
            self._conn.commit()
            print("⚠️  检测到旧版账本，已归档为 %s（旧码全部作废，需重新发放）" % backup,
                  file=sys.stderr)
            cols = []
        if not cols:
            self._conn.execute(
                "CREATE TABLE IF NOT EXISTS issued ("
                " hwid TEXT PRIMARY KEY,"
                " uid TEXT NOT NULL,"
                " code_id TEXT NOT NULL UNIQUE,"
                " code TEXT NOT NULL,"
                " ts INTEGER NOT NULL"
                ")"
            )
            self._conn.commit()

    def get_by_hwid(self, hwid):
        return self._conn.execute(
            "SELECT hwid, uid, code_id, code, ts FROM issued WHERE hwid = ?",
            (norm_hwid(hwid),),
        ).fetchone()

    def get_by_uid(self, uid):
        return self._conn.execute(
            "SELECT hwid, uid, code_id, code, ts FROM issued WHERE uid = ? ORDER BY ts",
            (str(uid),),
        ).fetchall()

    def count_by_uid(self, uid):
        return self._conn.execute(
            "SELECT COUNT(*) FROM issued WHERE uid = ?", (str(uid),)
        ).fetchone()[0]

    def used_ids(self):
        return set(row[0] for row in self._conn.execute("SELECT code_id FROM issued"))

    def put(self, uid, hwid, code_id, code):
        self._conn.execute(
            "INSERT OR REPLACE INTO issued (hwid, uid, code_id, code, ts) VALUES (?,?,?,?,?)",
            (norm_hwid(hwid), str(uid), code_id, code, int(time.time())),
        )
        self._conn.commit()

    def drop_hwid(self, hwid):
        cur = self._conn.execute("DELETE FROM issued WHERE hwid = ?", (norm_hwid(hwid),))
        self._conn.commit()
        return cur.rowcount

    def drop_uid(self, uid):
        """解绑某个账号下**所有**机器。别人顶到上限时用这个救。"""
        cur = self._conn.execute("DELETE FROM issued WHERE uid = ?", (str(uid),))
        self._conn.commit()
        return cur.rowcount

    def all(self):
        return self._conn.execute(
            "SELECT hwid, uid, code_id, code, ts FROM issued ORDER BY ts"
        ).fetchall()

    def count(self):
        return self._conn.execute("SELECT COUNT(*) FROM issued").fetchone()[0]

    def close(self):
        self._conn.close()


def fmt_ts(ts):
    try:
        return time.strftime("%Y-%m-%d %H:%M", time.localtime(int(ts)))
    except Exception:
        return str(ts)


class PoolExhausted(Exception):
    pass


class TooManyDevices(Exception):
    pass


def issue_for(uid, hwid, ledger=None, explicit_id=None):
    """发码。返回 (code, is_new)。

    规则：
      · 同一台机器（hwid）永远只返回同一个码 —— 这是「别人不能再用」的根
      · 换机器 = 换 hwid = 发新码，旧码在新机器上验签必失败，自然作废
      · 同一个 uid 最多绑 MAX_DEVICES_PER_UID 台机器（默认 2），
        超了抛 TooManyDevices，必须由管理先解绑
    池子耗尽时抛 PoolExhausted。
    """
    uid = str(uid).strip()
    hwid = norm_hwid(hwid)
    if not hwid_valid(hwid):
        raise ValueError("机器码不合法，应为 8 位十六进制")
    if not uid:
        raise ValueError("uid 不能为空")

    own = ledger is None
    if own:
        ledger = Ledger(DB_PATH)
    try:
        row = ledger.get_by_hwid(hwid)
        if row:
            return row[3], False

        bound = ledger.count_by_uid(uid)
        if bound >= MAX_DEVICES_PER_UID:
            # 注意：这里只是陈述事实。**不要**把解绑办法写进异常文案，
            # 机器人会把它当成玩家可见内容转发出去。
            raise TooManyDevices(
                "这个账号已经绑了 %d 台机器，达到上限 %d 台。"
                % (bound, MAX_DEVICES_PER_UID)
            )

        pool = load_pool()
        if not pool:
            raise PoolExhausted("池子为空，先跑 poolgen 或编辑 tools/codes_pool.txt")

        used = ledger.used_ids()
        if explicit_id:
            code_id = str(explicit_id).strip().upper()
            if not id_valid(code_id):
                raise ValueError("指定的 ID 不合法：%s" % code_id)
            if code_id not in pool:
                raise ValueError("指定的 ID 不在池子里：%s" % code_id)
            if code_id in used:
                raise ValueError("指定的 ID 已经被用掉了：%s" % code_id)
        else:
            available = [i for i in pool if i not in used]
            if not available:
                raise PoolExhausted("池子里 %d 个码已经全部发完，加码后继续" % len(pool))
            code_id = available[0]

        code = make_code(code_id, hwid)
        ledger.put(uid, hwid, code_id, code)
        return code, True
    finally:
        if own:
            ledger.close()


# ---------------------------------------------------------------- 子命令

def cmd_poolgen(argv):
    args = [a for a in argv if not a.startswith("--")]
    count = int(args[0]) if args else 100
    pool = load_pool()
    new_ids = gen_ids(count, pool)
    save_pool(pool + new_ids)
    print("已生成 %d 个新码，池子共 %d 个 -> %s" % (count, len(pool) + len(new_ids), POOL_PATH))
    return 0


def cmd_pool(_argv):
    pool = load_pool()
    if not pool:
        print("池子为空（%s）" % POOL_PATH)
        return 0
    ledger = Ledger(DB_PATH)
    try:
        used = ledger.used_ids()
    finally:
        ledger.close()
    remaining = [i for i in pool if i not in used]
    issued_from_pool = len(used & set(pool))
    print("池子 %d 个：已发 %d，剩余 %d" % (len(pool), issued_from_pool, len(remaining)))
    if remaining:
        print("下一个会发：" + remaining[0])
    else:
        print("⚠️  池子已空，跑 poolgen 加码")
    return 0


def cmd_issue(argv):
    explicit = None
    if "--id" in argv:
        i = argv.index("--id")
        if i + 1 >= len(argv):
            print("--id 后面要跟池子里的码 ID", file=sys.stderr)
            return 1
        explicit = argv[i + 1]
        argv = argv[:i] + argv[i + 2:]
    args = [a for a in argv if not a.startswith("--")]
    if len(args) < 2:
        print("用法: issue <QQ号或openid> <机器码> [--id 指定池子里的某个ID]", file=sys.stderr)
        print("机器码 = 游戏内授权窗口里的「本机识别码」，8 位十六进制", file=sys.stderr)
        return 1
    uid = str(args[0]).strip()
    hwid = norm_hwid(args[1])
    if not uid:
        print("uid 不能为空", file=sys.stderr)
        return 1
    if not hwid_valid(hwid):
        print("机器码不合法：%r（应为 8 位十六进制，如 1A2B3C4D）" % args[1], file=sys.stderr)
        return 1

    ledger = Ledger(DB_PATH)
    try:
        row = ledger.get_by_hwid(hwid)
        if row:
            print(row[3])
            print("# 这台机器已发放过（%s），返回原码" % fmt_ts(row[4]), file=sys.stderr)
            return 0
        code, _is_new = issue_for(uid, hwid, ledger, explicit)
        print(code)
        return 0
    except PoolExhausted as exc:
        print("# %s" % exc, file=sys.stderr)
        return 3
    except TooManyDevices as exc:
        print("# %s" % exc, file=sys.stderr)
        print("# （仅管理可见）要解绑该账号全部机器："
              "python tools/qq_auth.py revoke --uid %s" % uid, file=sys.stderr)
        return 4
    except ValueError as exc:
        print("# %s" % exc, file=sys.stderr)
        return 1
    finally:
        ledger.close()


def cmd_revoke(argv):
    if "--uid" in argv:
        i = argv.index("--uid")
        if i + 1 >= len(argv):
            print("--uid 后面要跟账号标识（账本里的 uid/openid）", file=sys.stderr)
            return 1
        uid = argv[i + 1].strip()
        ledger = Ledger(DB_PATH)
        try:
            n = ledger.drop_uid(uid)
            if n:
                print("已解绑 %s 名下的 %d 台机器，该账号可以重新领码" % (uid, n))
                return 0
            print("账本里没有这个账号：%s" % uid, file=sys.stderr)
            return 2
        finally:
            ledger.close()

    args = [a for a in argv if not a.startswith("--")]
    if not args:
        print("用法: revoke <机器码>        让这台机器上的码失效，下次重新领", file=sys.stderr)
        print("      revoke --uid <账号>    解绑该账号名下所有机器（顶到上限时用）", file=sys.stderr)
        return 1
    hwid = norm_hwid(args[0])
    if not hwid_valid(hwid):
        print("机器码不合法", file=sys.stderr)
        return 1
    ledger = Ledger(DB_PATH)
    try:
        n = ledger.drop_hwid(hwid)
        if n:
            print("已作废机器 %s 的授权，玩家需要用本机识别码重新领码" % hwid)
            return 0
        print("账本里没有这台机器：%s" % hwid, file=sys.stderr)
        return 2
    finally:
        ledger.close()


def cmd_ledger(_argv):
    ledger = Ledger(DB_PATH)
    try:
        rows = ledger.all()
        if not rows:
            print("还没有发放记录")
            return 0
        print("共 %d 条" % len(rows))
        print("%-10s %-34s %-10s %-30s %s" % ("机器码", "用户(QQ/openid)", "码ID", "授权码", "发放时间"))
        for hwid, uid, code_id, code, ts in rows:
            print("%-10s %-34s %-10s %-30s %s" % (hwid, uid, code_id, code, fmt_ts(ts)))
        return 0
    finally:
        ledger.close()


def cmd_export(argv):
    args = [a for a in argv if not a.startswith("--")]
    out = args[0] if args else "qq_export.csv"
    ledger = Ledger(DB_PATH)
    try:
        rows = ledger.all()
        with open(out, "w", encoding="utf-8-sig") as fh:
            fh.write("hwid,uid,code_id,code,issued_at\n")
            for hwid, uid, code_id, code, ts in rows:
                fh.write("%s,%s,%s,%s,%s\n" % (hwid, uid, code_id, code, fmt_ts(ts)))
        print("已导出 %d 条 -> %s" % (len(rows), out))
        return 0
    finally:
        ledger.close()


def cmd_verify(argv):
    args = [a for a in argv if not a.startswith("--")]
    if not args:
        print("用法: verify <授权码>")
        return 1
    ok, code_id, hwid = verify(args[0])
    if ok:
        print("签名有效  码ID=%s  绑定机器=%s" % (code_id, hwid))
        print("（只有机器码为 %s 的那台机器能用这个码）" % hwid)
        return 0
    print("无效")
    return 2


def cmd_gml(_argv):
    cut = max(1, len(SECRET) // 3)
    a, b, c = SECRET[:cut], SECRET[cut:cut * 2], SECRET[cut * 2:]
    assert a + b + c == SECRET
    print("// ======== 覆盖 scripts/auth_client/auth_client.gml 顶部这段 ========")
    print('#macro kAuthPrefix "%s"' % FORMAT)
    print('#macro kAuthSecretA "%s"' % a)
    print('#macro kAuthSecretB "%s"' % b)
    print('#macro kAuthSecretC "%s"' % c)
    print('#macro kAuthSealKey "%s"'
          % hashlib.md5((SECRET + "|seal").encode("utf-8")).hexdigest().upper()[:24])
    return 0


def selftest():
    HWID_A = "1A2B3C4D"
    HWID_B = "9F8E7D6C"

    code = make_code("8F3K2M9Q", HWID_A)
    ok, code_id, hwid = verify(code)
    assert ok and code_id == "8F3K2M9Q" and hwid == HWID_A, code

    # 改签名无效
    assert verify(code[:-1] + ("2" if code[-1] != "2" else "3"))[0] is False
    # 换机器码 = 签名对不上 → 这正是「别人拿到也用不了」的核心
    assert verify("FVM4-8F3K2M9Q-%s-%s" % (HWID_B, sign("8F3K2M9Q", HWID_A)))[0] is False
    # 换 ID
    assert verify("FVM4-AAAAAAAA-%s-%s" % (HWID_A, sign("8F3K2M9Q", HWID_A)))[0] is False
    # 格式垃圾
    for bad in ["", "FVM4", "FVM4-8F3K2M9Q", "FVM3-8F3K2M9Q-%s" % sign("8F3K2M9Q", HWID_A),
                "FVM4-8F3K2M9Q-%s" % HWID_A, "FVM4-8F3K2M9Q-%s-%s" % (HWID_A, sign("8F3K2M9Q", HWID_A).lower()[:-1])]:
        assert verify(bad)[0] is False, bad
    # ID / 机器码字符集
    assert id_valid("8F3K2M9Q") is True
    assert id_valid("8F3K2M9O") is False   # 字母 O 被排除
    assert id_valid("ABC") is False
    assert hwid_valid("1A2B3C4D") is True
    assert hwid_valid("1A2B3C4") is False
    assert norm_hwid(" 1a2b-3c4d ") == "1A2B3C4D"

    # 池子 + 发放：换到临时目录跑，别污染真实数据
    global POOL_PATH, DB_PATH
    origin_pool, origin_db = POOL_PATH, DB_PATH
    tmp_pool = os.path.join(HERE, "_selftest_pool.txt")
    tmp_db = os.path.join(HERE, "_selftest.db")
    for p in (tmp_pool, tmp_db):
        if os.path.exists(p):
            os.remove(p)
    try:
        POOL_PATH, DB_PATH = tmp_pool, tmp_db
        save_pool(gen_ids(4, []))
        led = Ledger(tmp_db)
        try:
            c1, new1 = issue_for("u1", HWID_A, led)
            c2, new2 = issue_for("u1", HWID_A, led)
            assert c1 == c2 and new1 is True and new2 is False, "同一台机器必须返回同一个码"
            assert verify(c1)[0] is True

            # 同一台机器换个人来领，也还是原码（机器是唯一键）
            c3, new3 = issue_for("u2", HWID_A, led)
            assert c3 == c1 and new3 is False

            # 换机器 → 新码，且旧码在新机器上无效
            c4, new4 = issue_for("u1", HWID_B, led)
            assert new4 is True and c4 != c1
            assert verify(c4)[2] == HWID_B
            assert verify(c1)[2] == HWID_A

            # 一个 uid 多机器受上限约束：u1 现在已占 HWID_A + HWID_B 两台
            assert led.count_by_uid("u1") == 2, "u1 应已绑 2 台"

            # 超上限必须抛 TooManyDevices，不能悄悄发新码
            over = "%08X" % 0x33330000
            try:
                issue_for("u1", over, led)
                raise AssertionError("超出 %d 台上限仍发了码" % MAX_DEVICES_PER_UID)
            except TooManyDevices:
                assert led.get_by_hwid(over) is None, "被拒的机器不该进账本"

            # 解绑后可以重新领
            assert led.drop_uid("u1") == 2
            c_again, new_again = issue_for("u1", HWID_B, led)
            assert new_again is True and c_again != c4, "解绑后应能重新领码"

            # 池子耗尽
            try:
                for i in range(10):
                    issue_for("pool%d" % i, "%08X" % (0x22220000 + i), led)
                raise AssertionError("池子应当耗尽")
            except PoolExhausted:
                pass

            # 作废
            assert led.drop_hwid(HWID_B) == 1
            assert led.get_by_hwid(HWID_B) is None
        finally:
            led.close()
    finally:
        POOL_PATH, DB_PATH = origin_pool, origin_db
        for p in (tmp_pool, tmp_db):
            if os.path.exists(p):
                os.remove(p)
    print("selftest ok")


COMMANDS = {
    "poolgen": cmd_poolgen,
    "pool": cmd_pool,
    "issue": cmd_issue,
    "revoke": cmd_revoke,
    "ledger": cmd_ledger,
    "export": cmd_export,
    "verify": cmd_verify,
    "gml": cmd_gml,
}


def main():
    argv = sys.argv[1:]
    if not argv:
        print(__doc__)
        return 0
    name, rest = argv[0], argv[1:]
    if name == "selftest":
        selftest()
        return 0
    if name not in COMMANDS:
        print("未知命令: %s" % name)
        print("可用: %s, selftest" % ", ".join(COMMANDS))
        return 1
    return COMMANDS[name](rest)


if __name__ == "__main__":
    sys.exit(main())
