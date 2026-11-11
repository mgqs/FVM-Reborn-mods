#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""群成员登记表 —— 独立于绑定账本。

为什么单独一个对象
------------------
`ledger.json` 记的是「哪台机器领了哪个码」，只在发码时写一次；
这张表记的是「谁在群里、什么时候进来的、最后一次说话是哪天」，
每条群消息都可能触发更新。混在一起写会有两个后果：

  1. 每次发言都要把整份绑定账本读出来再写回去，COS 上高频 PUT，
     互相覆盖的概率和窗口都成倍放大；
  2. 一次写入失败会同时伤到发码数据和成员数据。

所以物理隔离：`qqauth/ledger.json` 与 `qqauth/members.json` 两个对象，
各写各的。

时间字段的存法
--------------
`last_speak_day` 存 `YYYYMMDD` 整数，不存秒。理由：群里每条消息都写一遍
COS 是不可接受的，存「天」的话，同一天内第二句话之后就不用再写了
（`touch_speak()` 返回 False，调用方跳过 flush）。判定精度要求也只是「天」。
"""

import time

DAY = 86400


def today(now=None):
    """本地日期 → 20261111 这样的整数。"""
    return int(time.strftime("%Y%m%d", time.localtime(now or time.time())))


def day_of(ts):
    """时间戳 → 同口径的日期整数。0 视为未知，返回 0。"""
    try:
        ts = int(ts)
    except (TypeError, ValueError):
        return 0
    if ts <= 0:
        return 0
    return int(time.strftime("%Y%m%d", time.localtime(ts)))


def new_member(ts, name="", role="member"):
    return {
        "join_ts": int(ts),
        "last_speak_ts": 0,
        "last_speak_day": 0,
        "name": str(name or ""),
        "role": str(role or "member"),
        "union": "",
        "bound": False,
        "bound_ts": 0,
        "state": "active",
        "warned_at": 0,
        "warn_kind": "",
        "warn_msg_id": "",
        "kick_ts": 0,
        "kick_reason": "",
        "exempt": False,
        "exempt_by": "",
    }


_REQUIRED = tuple(new_member(0).keys())


def _blank(group=""):
    return {"group": str(group or ""), "members": {}, "blacklist": {}, "meta": {}}


def _fill_defaults(rec):
    """老记录缺字段时补上，别让升级后的第一次读就 KeyError。"""
    changed = False
    for k in _REQUIRED:
        if k not in rec:
            rec[k] = new_member(0)[k]
            changed = True
    return changed


class Members(object):
    """成员表。store 只要求有 load()/save() 两个方法。"""

    def __init__(self, store, group=""):
        self.store = store
        raw = store.load() or {}
        if not isinstance(raw, dict):
            raise RuntimeError("成员表格式损坏：不是 JSON 对象")
        self.data = raw
        self.data.setdefault("group", str(group or ""))
        self.data.setdefault("members", {})
        self.data.setdefault("blacklist", {})
        self.data.setdefault("meta", {})
        self._dirty = False
        for rec in self.data["members"].values():
            if isinstance(rec, dict) and _fill_defaults(rec):
                self._dirty = True

    # ── 基础 ──
    @property
    def group(self):
        return self.data.get("group") or ""

    def members(self):
        return self.data["members"]

    def get(self, mid):
        return self.data["members"].get(str(mid))

    def count(self):
        return len(self.data["members"])

    def dirty(self):
        return self._dirty

    def flush(self):
        if not self._dirty:
            return False
        self.store.save(self.data)
        self._dirty = False
        return True

    def close(self):
        return self.flush()

    # ── 成员进出 ──
    def add_member(self, mid, ts=None, name="", role="member"):
        """入群登记。已存在就不覆盖 join_ts（重复推送 / 重连补发都不能重算 3 天）。"""
        mid = str(mid or "").strip()
        if not mid:
            return None
        ts = int(ts or time.time())
        rec = self.data["members"].get(mid)
        if rec is None:
            rec = new_member(ts, name, role)
            self.data["members"][mid] = rec
            self._dirty = True
            return rec
        bumped = False
        if name and rec.get("name") != name:
            rec["name"] = str(name)
            bumped = True
        if bumped:
            self._dirty = True
        return rec

    def remove_member(self, mid):
        """退群。不删记录，标成 left —— 留痕才能解释「为什么没踢他」。"""
        rec = self.get(mid)
        if rec is None:
            return False
        if rec.get("state") != "left":
            rec["state"] = "left"
            self._dirty = True
        return True

    def touch_speak(self, mid, name="", union="", role="", ts=None):
        """记一次发言。同一天里第二次之后返回 False（调用方据此省掉一次 COS 写）。"""
        mid = str(mid or "").strip()
        if not mid:
            return False
        ts = int(ts or time.time())
        rec = self.data["members"].get(mid)
        if rec is None:
            # 机器人上线前就在群的人，第一次说话时补登记。
            # join_ts 用「现在」——对他的 3 天倒计时从这里开始，
            # 这是保护存量成员的唯一办法（他们没有入群事件）。
            rec = new_member(ts, name, role or "member")
            rec["state"] = "joined_late"
            self.data["members"][mid] = rec
            self._dirty = True
        d = day_of(ts)
        changed = False
        if rec.get("last_speak_day") != d:
            rec["last_speak_day"] = d
            rec["last_speak_ts"] = ts
            changed = True
        if name and rec.get("name") != name:
            rec["name"] = str(name)
            changed = True
        if union and rec.get("union") != union:
            rec["union"] = str(union)
            changed = True
        if role and rec.get("role") != role:
            rec["role"] = str(role)
            changed = True
        if rec.get("state") in ("kicked", "exempt"):
            pass
        elif rec.get("state") == "left":
            rec["state"] = "active"
            changed = True
        if rec.get("warned_at") and changed and rec.get("last_speak_day") == d:
            # 一说话就进警告窗口外，下一轮 sweep 会自己重算 deadline
            pass
        if changed:
            self._dirty = True
        return changed

    def mark_bound(self, mid, ts=None):
        rec = self.get(mid)
        if rec is None:
            return False
        if rec.get("bound"):
            return False
        rec["bound"] = True
        rec["bound_ts"] = int(ts or time.time())
        if rec.get("state") == "active":
            rec["state"] = "bound"
        self._dirty = True
        return True

    def set_state(self, mid, state, reason=""):
        rec = self.get(mid)
        if rec is None:
            return False
        rec["state"] = str(state)
        if reason:
            rec["kick_reason"] = str(reason)
        self._dirty = True
        return True

    def set_exempt(self, mid, exempt, by=""):
        rec = self.get(mid)
        if rec is None:
            return False
        if bool(rec.get("exempt")) == bool(exempt) and rec.get("exempt_by") == str(by):
            return False
        rec["exempt"] = bool(exempt)
        rec["exempt_by"] = str(by or "")
        self._dirty = True
        return True

    def set_name(self, mid, name):
        rec = self.get(mid)
        if rec is None or not name or rec.get("name") == name:
            return False
        rec["name"] = str(name)
        self._dirty = True
        return True

    # ── 黑名单 ──
    def blacklist(self):
        return self.data["blacklist"]

    def is_blacklisted(self, mid, now=None):
        """expire_ts=0 表示永久。过期的不算，顺手清掉。"""
        mid = str(mid or "").strip()
        item = self.data["blacklist"].get(mid)
        if not item:
            return False
        exp = int(item.get("expire_ts") or 0)
        if exp and int(now or time.time()) >= exp:
            del self.data["blacklist"][mid]
            self._dirty = True
            return False
        return True

    def blacklist_add(self, mid, why="", expire_days=0, now=None):
        mid = str(mid or "").strip()
        if not mid:
            return False
        now = int(now or time.time())
        exp = 0 if not expire_days else now + int(expire_days) * DAY
        self.data["blacklist"][mid] = {
            "ts": now,
            "why": str(why or ""),
            "expire_ts": exp,
        }
        self._dirty = True
        return True

    def blacklist_del(self, mid):
        mid = str(mid or "").strip()
        if mid in self.data["blacklist"]:
            del self.data["blacklist"][mid]
            self._dirty = True
            return True
        return False

    def blacklist_find(self, prefix):
        """按 openid 前缀找。管理员手里只有前缀，没法抄全。"""
        prefix = str(prefix or "").strip().upper()
        if not prefix:
            return []
        return [m for m in self.data["blacklist"]
                if m.upper().startswith(prefix)]

    # ── meta ──
    def meta_set(self, key, value):
        self.data["meta"][str(key)] = value
        self._dirty = True

    def meta_get(self, key, default=None):
        return self.data["meta"].get(str(key), default)

    # ── 迁移：用账本反查谁已经绑过 ──
    def sync_bound_from_ledger(self, uid_to_rows):
        """uid_to_rows: {member_openid: [账本行, ...]}。

        上线新功能时，机器人不知道历史成员绑没绑过（原来存的是 union/私聊
        openid）。这里按调用方给的映射补一遍，避免第一次 sweep 把老玩家全踢了。
        """
        n = 0
        for mid, rows in uid_to_rows.items():
            if rows and self.mark_bound(mid):
                n += 1
        return n


# ---------------------------------------------------------------- 工厂

def members_from_env(store_obj=None, autosave=True, group=""):
    """按环境变量决定成员表存哪。

    默认对象 `qqauth/members.json`，和账本 `qqauth/ledger.json` 分开 ——
    成员表每次发言都可能写，账本只在发码时写，混在一起会互相覆盖。
    """
    import os
    import store as store_mod

    if store_obj is not None:
        return Members(store_obj, group=group)

    sid = os.environ.get("COS_SECRET_ID", "").strip()
    skey = os.environ.get("COS_SECRET_KEY", "").strip()
    region = os.environ.get("COS_REGION", "").strip()
    bucket = os.environ.get("COS_BUCKET", "").strip()

    if sid and skey and region and bucket:
        key = (os.environ.get("COS_MEMBERS_KEY", "").strip()
               or "qqauth/members.json")
        client = store_mod.CosClient(sid, skey, region, bucket)
        return Members(store_mod.CosStore(client, key), group=group)

    path = os.environ.get("MEMBERS_FILE", "").strip() or "_members_debug.json"
    return Members(store_mod.FileStore(path), group=group)

