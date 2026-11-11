#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""群成员清理巡检 —— 由定时触发器每 15 分钟调一次。

规则（用户 2026-11 定的）
------------------------
1. 新人入群 3 天没绑定授权码 → 移出群 + 拉黑
2. 7 天没发言 → 移出群 + 拉黑
3. 到点前 1 小时 @ 他一次做提示
4. 群昵称含「留」字 → 永不清理（手动 /豁免 同理）

为什么要有 dry_run
------------------
`batch_remove_members` 目前还在内邀（报 11253），新申请的机器人很容易拿到
「无权限」。默认 `KICK_MODE=dry_run`：只算名单、只发警告、绝不真踢，
先让管理员用 `/待清理` 观察一两天，确认没有误判再改成 `remove`。
改了 `remove` 之后若仍报 11253，会自动退化成禁言（`mute`），不会静默失败。

一次调用做多少活
----------------
SCF 默认超时 3 秒，改成 900 秒后也仍是单次同步调用。警告和踢人各限 20 人/轮
（接口单次上限就是 20），剩下的下一轮接着来 —— 15 分钟一轮足够消化。
"""

import json
import time

import members as members_mod


def _token(bot):
    token, _ttl = bot.get_access_token()
    return token


def _group_id(bot, explicit=""):
    gid = (explicit or "").strip() or (bot.GROUP_OPENID or "").strip()
    return gid


def _audit(ledger, action, actor, target, detail):
    try:
        ledger.audit_append(action, actor, target, detail)
    except Exception:
        pass


def warn_one(handler, gid, item, token, bot):
    """发一条警告。返回 True 表示已发出（可写入 warned_at）。

    走主动消息（send_group_active）：巡检不来自任何一条群消息，手里没有
    msg_id，没法用被动回复。主动消息的频控是单群 20 条/分钟，所以
    sweep 里每轮最多发 20 条，正好卡满。
    """
    text = bot.warn_text(item)
    status, body = bot.send_group_active(token, gid, text)
    ok = status < 400
    handler._log("警告 %s(%s) -> %s %s"
                 % (item["mid"][:8], item["why"], status,
                    "" if ok else json.dumps(body, ensure_ascii=False)[:120]))
    return ok


def sweep(handler, now=None, mode=None):
    """跑一轮巡检。返回统计 dict（同时会打到日志里）。"""
    bot = handler.bot
    now = int(now or time.time())
    mode = (mode or bot.KICK_MODE or "dry_run").strip().lower()

    mem = handler.members_factory()
    led = handler.ledger_factory()
    stat = {"mode": mode, "warned": 0, "kicked": 0, "muted": 0,
            "skip": 0, "failed": 0, "round": 0}
    try:
        gid = _group_id(bot, mem.group)
        if not gid:
            handler._log("sweep 中止：没配 GROUP_OPENID，不知道对哪个群操作")
            return stat
        if not mem.group:
            mem.data["group"] = gid

        # 账本 → 成员表：把「已经绑过的人」标上。只做一次（meta 里记标记），
        # 之后靠发码时的实时标记，不必每轮都全表扫。
        if not mem.meta_get("bound_synced"):
            by_uid = {}
            for row in led.all():
                by_uid.setdefault(str(row[1]), []).append(row)
            n = mem.sync_bound_from_ledger(by_uid)
            mem.meta_set("bound_synced", int(now))
            handler._log("首次巡检：按账本补标 %d 人已绑定" % n)

        plan = bot.sweep_plan(mem, now)
        handler._log("巡检 mode=%s 成员=%d 待警告=%d 待处理=%d 跳过=%d"
                     % (mode, mem.count(), len(plan["warn"]),
                        len(plan["kick"]), len(plan["skip"])))
        stat["skip"] = len(plan["skip"])
        stat["round"] = int(mem.meta_get("sweep_round", 0)) + 1
        mem.meta_set("sweep_round", stat["round"])
        mem.meta_set("last_sweep", int(now))

        need_token = bool(plan["warn"] or plan["kick"])
        token = ""
        if need_token:
            try:
                token = _token(bot)
            except Exception as exc:
                handler._log("取 token 失败，本轮只记名单：%s" % exc)
                token = ""

        # ── 1) 警告 ──
        for item in plan["warn"][:20]:
            if not token:
                stat["failed"] += 1
                continue
            if warn_one(handler, gid, item, token, bot):
                rec = mem.get(item["mid"])
                if rec is not None:
                    rec["warned_at"] = int(now)
                    rec["warn_kind"] = item["why"]
                stat["warned"] += 1
                _audit(led, "warn", "sweep", item["mid"],
                       "%s hours=%d" % (item["why"], item["hours"]))
            else:
                stat["failed"] += 1
        if len(plan["warn"]) > 20:
            handler._log("还有 %d 个待警告，下一轮继续" % (len(plan["warn"]) - 20))

        # ── 2) 到点处理 ──
        if mode == "dry_run":
            for item in plan["kick"]:
                handler._log("DRY-RUN 该踢：%s(%s) 名字=%r"
                             % (item["mid"][:8], item["why"], item["name"]))
                _audit(led, "dry_run_would_kick", "sweep", item["mid"], item["why"])
            mem.flush()
            return stat

        victims = plan["kick"][:20]
        if not victims:
            mem.flush()
            return stat
        ids = [v["mid"] for v in victims]

        ok, status, body = (False, 0, {})
        if mode == "remove":
            if not token:
                stat["failed"] += len(ids)
                mem.flush()
                return stat
            ok, status, body = bot.kick_members(gid, ids, token)
            if not ok:
                code = str((body or {}).get("code") or "")
                handler._log("踢人失败 %s code=%s %s → 退化为禁言"
                             % (status, code,
                                json.dumps(body, ensure_ascii=False)[:160]))

        if not ok:
            # remove 失败（11253 内邀 / 没给管理员权限）或本来就是 mute 模式
            if not token:
                stat["failed"] += len(ids)
                mem.flush()
                return stat
            mok, mstatus, mbody = bot.mute_members(gid, ids, days=30, token=token)
            if not mok:
                handler._log("禁言也失败 %s %s" % (mstatus,
                             json.dumps(mbody, ensure_ascii=False)[:160]))
                stat["failed"] += len(ids)
                mem.flush()
                return stat
            for v in victims:
                mem.set_state(v["mid"], "muted",
                              bot.MSG_MUTED_NO_AUTH.format(days=bot.KICK_NO_AUTH_DAYS)
                              if v["why"] == "no_auth"
                              else bot.MSG_MUTED_IDLE.format(days=bot.KICK_IDLE_DAYS))
                mem.set_exempt(v["mid"], False, "")
                _audit(led, "mute", "sweep", v["mid"], v["why"])
            stat["muted"] = len(victims)
            handler._log("已禁言 %d 人（%d 天）" % (len(victims), 30))
            mem.flush()
            return stat

        for v in victims:
            mid = v["mid"]
            mem.set_state(mid, "kicked",
                          bot.MSG_KICKED_NO_AUTH.format(days=bot.KICK_NO_AUTH_DAYS)
                          if v["why"] == "no_auth"
                          else bot.MSG_KICKED_IDLE.format(days=bot.KICK_IDLE_DAYS))
            rec = mem.get(mid) or {}
            # 拉黑时把当时的昵称记进 why，日后 /解黑 时能对上人
            mem.blacklist_add(mid, why="%s;name=%s" % (v["why"], rec.get("name") or ""),
                              expire_days=bot.BLACKLIST_EXPIRE_DAYS, now=now)
            _audit(led, "kick", "sweep", mid, "%s name=%s"
                   % (v["why"], rec.get("name") or ""))
        stat["kicked"] = len(victims)
        handler._log("已踢出 %d 人" % len(victims))
        # ── 3) 踢成功了，顺手在 QQ 侧也拉黑 ──
        # 官方 member_blacklist 接口要求「目标不在群里」才能加，所以必须在
        # 踢成功之后调；它同样在内邀（11253），失败就算了 —— 我们自己的
        # members.json 黑名单才是真正生效的那一层（/解黑 也只改自己那份）。
        if bot.PUSH_QQ_BLACKLIST and victims:
            okb, statusb, bodyb = bot.blacklist_members(gid, ids, token=token, op="add")
            fails = (bodyb or {}).get("fail_openids") or []
            handler._log("QQ侧拉黑 %s status=%s fail=%d %s"
                         % ("✅" if okb else "❌", statusb, len(fails),
                            "" if okb else json.dumps(bodyb, ensure_ascii=False)[:120]))
            _audit(led, "qq_blacklist", "sweep", ",".join(m[:8] for m in ids),
                   "ok=%s status=%s fail=%s" % (okb, statusb, fails[:5]))

        mem.flush()
        return stat
    finally:
        try:
            mem.close()
        except Exception:
            pass
        try:
            led.close()
        except Exception:
            pass


def kick_one(handler, mid, why="manual", now=None):
    """管理员手动清退一个人（/解黑 的反操作，方便本地验证踢人链路通不通）。"""
    bot = handler.bot
    now = int(now or time.time())
    mem = handler.members_factory()
    led = handler.ledger_factory()
    try:
        gid = _group_id(bot, mem.group)
        if not gid or not mid:
            return False, "缺 group_openid 或 mid"
        token = _token(bot)
        ok, status, body = bot.kick_members(gid, [mid], token)
        if not ok:
            return False, "kick 失败 %s %s" % (status, json.dumps(body, ensure_ascii=False)[:100])
        mem.set_state(mid, "kicked", why)
        mem.blacklist_add(mid, why=why, expire_days=bot.BLACKLIST_EXPIRE_DAYS, now=now)
        mem.flush()
        _audit(led, "kick_manual", "admin", mid, why)
        return True, ""
    finally:
        try:
            mem.close()
        finally:
            led.close()
