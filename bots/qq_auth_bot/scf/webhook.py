#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""QQ 官方机器人 —— Webhook 回调处理。

和 WebSocket 版的区别只有一个：**谁先开口**。
WS 是机器人主动连上去等消息；Webhook 是腾讯主动 POST 过来。所以这个模块
不需要任何常驻进程，被调用才有计算发生——这正是「不用开电脑」的关键。

腾讯对回调的三条硬要求（都在这处理了）：
  1. 必须 HTTPS，端口只能是 80 / 443 / 8080 / 8443
  2. 每次请求都要用 Ed25519 验签（X-Signature-Ed25519 / -Timestamp）
  3. 保存回调地址时会发一次 op=13 握手，必须在 3 秒内返回正确签名

复用说明
--------
命令解析、文案、发码规则全部直接用 `bot.py` 里那份，不复制。
复制一份的后果是：改了 WS 版文案忘了同步，两边玩家看到不一样的话。
"""

import json
import time

import ed25519_ref as ed25519


class WebhookHandler(object):
    def __init__(self, app_id, app_secret, bot_module, ledger_factory,
                 verbose=True, secret_ok=True, members_factory=None):
        self.app_id = (app_id or "").strip()
        self.bot = bot_module
        self.ledger_factory = ledger_factory
        # 成员表工厂。不传就懒加载 scf/members.py 里的 members_from_env()，
        # 这样老的调用方（selftest / simulate）不用改也能跑。
        self._members_factory = members_factory
        self.verbose = verbose
        # 密钥没配好时仍然允许应答握手（否则回调地址都存不进去，
        # 反而更难查），但绝不允许真的发码——那种码游戏端一律验不过。
        self.secret_ok = secret_ok

        if not self.app_id:
            raise ValueError("缺少 QQ_APP_ID")
        # seed 由 Bot Secret 派生，两个都从同一份 secret 算，别混用
        self.seed = ed25519.seed_from_secret(app_secret)
        self.pubkey = ed25519.public_key(self.seed)

        self._token = None
        self._token_expire = 0

        # msg_seq：同一条消息多次回复要递增，否则会被平台去重丢掉。
        # 函数每次冷启动 MSG_SEQ 都是空的，用时间戳保证跨实例不撞。
        bot_module._next_seq = lambda msg_id: int(time.time() * 1000) % 900000 + 1

    @property
    def members_factory(self):
        if self._members_factory is None:
            import members as members_mod
            self._members_factory = members_mod.members_from_env
        return self._members_factory

    # ────────────────────────── 日志 ──────────────────────────
    def _log(self, fmt, *args):
        if self.verbose:
            print(("[scf] " + fmt) % args if args else ("[scf] " + fmt))

    # ────────────────────────── 验签 ──────────────────────────
    def verify_signature(self, headers, raw_body):
        """返回 (是否通过, 原因)。reason 只进日志，不回给调用方。"""
        lower = {}
        for key, value in (headers or {}).items():
            lower[str(key).lower()] = value

        sig_hex = (lower.get("x-signature-ed25519") or "").strip()
        timestamp = (lower.get("x-signature-timestamp") or "").strip()
        if not sig_hex or not timestamp:
            return False, "缺签名头（这个请求不是从腾讯过来的？）"

        try:
            signature = bytes.fromhex(sig_hex)
        except ValueError:
            return False, "签名头不是合法的十六进制"

        # 官方规则：签名对象是 timestamp 字符串拼上原始 body 字节
        message = timestamp.encode("utf-8") + raw_body
        if ed25519.verify(self.pubkey, message, signature):
            return True, ""
        return False, "验签失败（Bot Secret 对不上，或 body 被中间层改写了）"

    # ────────────────────────── 入口 ──────────────────────────
    def handle(self, headers, raw_body):
        """返回 (status_code, response_dict)。"""
        ok, reason = self.verify_signature(headers, raw_body)
        if not ok:
            self._log("拒绝：%s" % reason)
            return 401, {"error": "invalid signature"}

        try:
            payload = json.loads(raw_body.decode("utf-8"))
        except Exception as exc:
            self._log("body 不是合法 JSON：%s" % exc)
            return 400, {"error": "bad json"}

        op = payload.get("op")
        data = payload.get("d") or {}

        # op=13：平台在保存回调地址时发的校验握手
        if op == 13:
            plain_token = data.get("plain_token", "")
            event_ts = data.get("event_ts", "")
            if not plain_token or not event_ts:
                self._log("握手请求缺字段：%s" % json.dumps(payload)[:200])
                return 400, {"error": "bad validation payload"}
            signature = ed25519.sign(self.seed, (event_ts + plain_token).encode("utf-8"))
            self._log("握手校验已应答")
            return 200, {"plain_token": plain_token, "signature": signature.hex()}

        if op == 0:
            event_name = payload.get("t", "")
            try:
                self._on_event(event_name, data)
            except Exception as exc:
                # 事件处理失败也要回 200，否则平台会一直重推同一条
                self._log("事件处理异常 %s：%s" % (event_name, exc))
                import traceback
                traceback.print_exc()
            return 200, {}

        # op 1/11 这类心跳在 Webhook 模式下不会出现，兜底回 200
        self._log("收到未处理的 op=%s" % op)
        return 200, {}

    # ────────────────────────── 事件 ──────────────────────────
    def _on_event(self, name, data):
        bot = self.bot

        # ── 群成员进出：这是「3 天未绑定」规则的唯一触发点 ──
        if name == "GROUP_MEMBER_ADD":
            self._on_member_add(data)
            return

        if name == "GROUP_MEMBER_REMOVE":
            self._on_member_remove(data)
            return

        if name == "GROUP_MESSAGE_CREATE":
            # 全量模式：群里每句话都推（不限 @）。只用来记「最后发言时间」，
            # 不回复——每条都回会被当成刷屏。
            self._on_group_message(data, allow_reply=False)
            return

        if name == "GROUP_AT_MESSAGE_CREATE":
            self._on_group_message(data, allow_reply=True)
            return

        if name == "C2C_MESSAGE_CREATE":
            uid = bot.uid_of(data, prefer="user")
            if not uid:
                return
            text = data.get("content", "")
            msg_id = data.get("id", "")
            self._log("私聊 %s %r" % (uid[:12], text[:30]))
            # 授权统一在群里办：私聊只回一句指引，不发码也不处理管理命令。
            # 原来的实现会在私聊里发码，导致账本里混进 user_openid，
            # 而群成员事件只给 member_openid —— 两边对不上就会被误踢。
            out = self._handle_text(uid, text, allow_admin=True, channel="c2c")
            if out:
                self._send_c2c(uid, out, msg_id)
            return

        self._log("事件 %s 不处理" % name)

    # ── 成员表相关的三个小处理器 ──

    def _members(self):
        return self.members_factory()

    def _on_member_add(self, data):
        """入群登记。事件体只有 group_openid + member_openid + timestamp。"""
        bot = self.bot
        mid = str(data.get("member_openid") or "").strip()
        gid = str(data.get("group_openid") or "").strip()
        ts = int(data.get("timestamp") or time.time())
        if not mid:
            self._log("GROUP_MEMBER_ADD 缺 member_openid，跳过")
            return
        mem = self._members()
        try:
            if not mem.group and gid:
                mem.data["group"] = gid
            rec = mem.add_member(mid, ts)
            is_new = rec is not None and rec.get("join_ts") == ts
            # 黑名单里的人又回来了：直接记下来，交给下一轮 sweep 处理
            black = mem.is_blacklisted(mid)
            mem.meta_set("last_join", ts)
            mem.flush()
            self._log("入群登记 %s group=%s new=%s blacklisted=%s"
                      % (mid[:10], gid[:10], is_new, black))
        finally:
            mem.close()

    def _on_member_remove(self, data):
        bot = self.bot
        mid = str(data.get("member_openid") or "").strip()
        if not mid:
            return
        mem = self._members()
        try:
            mem.remove_member(mid)
            mem.flush()
            self._log("退群 %s" % mid[:10])
        finally:
            mem.close()

    def _on_group_message(self, data, allow_reply=True):
        """群消息统一入口：先记发言、再决定要不要回。"""
        bot = self.bot
        gid = str(data.get("group_openid") or "").strip()
        mid = str(data.get("member_openid") or "").strip()
        text = data.get("content", "")
        msg_id = data.get("id", "")
        author = data.get("author") or {}

        if not mid:
            # 老字段兜底（极少数事件里 author 结构不同）
            mid = str(bot.uid_of(data) or "").strip()

        if mid:
            # 记发言只是「顺手」，任何失败都不许影响后面的回复。
            # 云函数里代码目录是只读的，COS 没配好时 FileStore 会写盘失败，
            # 早期版本没兜住这个异常，表现就是「@ 了机器人完全没反应」。
            try:
                mem = self._members()
                try:
                    if not mem.group and gid:
                        mem.data["group"] = gid
                    # 昵称里带「留」就靠这个字段判断，所以每次发言都刷新一遍
                    changed = mem.touch_speak(
                        mid,
                        name=str(author.get("username") or ""),
                        union=str(author.get("union_openid") or ""),
                        role=str(author.get("member_role") or ""),
                    )
                    if changed:
                        mem.flush()   # 同一天的第二句之后 changed=False，省掉一次 COS 写
                finally:
                    mem.close()
            except Exception as exc:
                self._log("记发言失败（不影响回复）：%s" % exc)

        if not allow_reply:
            return   # 全量模式只看不说话

        self._log("群@ %s group=%s %r"
                  % (mid[:10], gid[:10], str(text)[:40]))
        if not gid or not msg_id:
            self._log("跳过：缺 group_openid / msg_id")
            return
        if bot.ALLOW_GROUP_ISSUE:
            out = self._handle_text(mid, text)
            if out:
                self._send_group(gid, out, msg_id)
            else:
                self._log("忽略：没命中命令（需要 %s 加识别码）"
                          % " / ".join(bot.AUTH_CMDS))
        elif bot.parse_command(text):
            self._send_group(gid,
                             bot.MSG_GROUP_HINT.format(cmd=bot.AUTH_COMMAND),
                             msg_id)
        else:
            # 群内发码关掉时，也允许玩家自查豁免（只读，不涉及发码）
            adm = bot.parse_admin_command(text)
            if adm is not None and adm[0] == "exempt" and not str(adm[1] or "").strip():
                self._send_group(gid, self._exempt_self(mid), msg_id)

    def _exempt_self(self, uid):
        """群内自查豁免。成员表挂掉也得回一句人话，不能沉默。"""
        mem = None
        try:
            mem = self._members()
            return self.bot.exempt_self_text(uid, mem)
        except Exception as exc:
            self._log("自查豁免失败 %s：%s" % (str(uid)[:10], exc))
            return self.bot.exempt_self_text(uid, None)
        finally:
            if mem is not None:
                try:
                    mem.close()
                except Exception:
                    pass

    def _handle_text(self, uid, text, allow_admin=False, channel="group"):
        """把发码这件事接到 COS 账本上，其余逻辑全用 bot.py 的。

        allow_admin：管理员命令只在私聊生效。群里 @ 一律不给 ——
        /绑定数量 虽然不再贴明细，但 /解绑、/豁免 这些改数据的操作被
        别人看到也是麻烦，所以管理命令的入口收在私聊。

        channel="c2c"：私聊只回指引，不发码（授权统一在群内办）。

        例外：/豁免 不带参数只读成员表、只回发起人自己的状态，群里也放行
        （见下）。改成数据的那一半 /豁免 <别人> 仍然只在私聊生效。
        """
        bot = self.bot

        if channel == "c2c":
            # 私聊不走发码链路，也不处理管理命令 —— 后者由
            # handle_message 里 parse_admin_command 单独判断，这里保留，
            # 因为管理员认领只能在私聊完成。
            adm = bot.parse_admin_command(text)
            if adm is not None and allow_admin:
                return self._run_admin(uid, adm)
            if bot.parse_command(text):
                return bot.MSG_C2C_REDIRECT.format(cmd=bot.AUTH_COMMAND)
            if bot.strip_mention(text) == "":
                return bot.MSG_GREETING.format(cmd=bot.AUTH_COMMAND)
            return None

        # 管理员命令要先于发码判断，而且**不走 secret_ok 那道闸**：
        # 认领管理员、解绑设备都不涉及签名密钥，密钥没配好也得能解绑。
        adm = bot.parse_admin_command(text)
        if adm is not None:
            if not allow_admin:
                # 唯一的例外：/豁免 不带参数是「查我自己」，只读成员表、
                # 不透露任何别人的信息，所以群里也放行。玩家想知道自己会
                # 不会被踢，不必等到清理前 1 小时的警告。
                if adm[0] == "exempt" and not str(adm[1] or "").strip():
                    out = self._exempt_self(uid)
                    self._log("群内自查豁免 uid=%s" % str(uid)[:10])
                    return out
                self._log("群里收到管理命令 %s，已忽略（仅私聊可用）" % adm[0])
                return None
            return self._run_admin(uid, adm)

        parsed = bot.parse_command(text)
        if parsed is None:
            return (bot.MSG_GREETING.format(cmd=bot.AUTH_COMMAND)
                    if bot.strip_mention(text) == "" else None)

        if not self.secret_ok:
            self._log("拒绝发码：授权签名密钥还是占位符，配好 AUTH_SECRET 再重启")
            return "机器人还没配置好，请联系管理。"

        _cmd, arg = parsed
        hwid = bot.qq_auth.norm_hwid(arg)
        if not arg:
            return bot.MSG_NEED_HWID.format(cmd=bot.AUTH_COMMAND)
        if not bot.qq_auth.hwid_valid(hwid):
            return bot.MSG_BAD_HWID

        try:
            code, is_new = self._issue(uid, hwid)
            self._log("发码 uid=%s hwid=%s new=%s code=%s"
                      % (uid[:12], hwid, is_new, code))
            self._mark_bound(uid)
            return bot.MSG_CODE.format(code=code)
        except bot.qq_auth.PoolExhausted:
            return bot.MSG_POOL_EMPTY
        except bot.qq_auth.TooManyDevices as exc:
            self._log("上限：%s（玩家只看到「绑满了」）" % exc)
            return bot.MSG_TOO_MANY.format(n=bot.qq_auth.MAX_DEVICES_PER_UID)
        except Exception as exc:
            self._log("发码失败 uid=%s：%s" % (uid, exc))
            import traceback
            traceback.print_exc()
            return bot.MSG_ERROR

    def _run_admin(self, uid, adm):
        bot = self.bot
        if adm[0] == "whoami":
            return bot.handle_admin(uid, adm[0], adm[1], None)
        ledger = self.ledger_factory()
        mem = None
        try:
            if adm[0] in ("pending", "exempt", "unblack", "query"):
                mem = self._members()
            out = bot.handle_admin(uid, adm[0], adm[1], ledger, members=mem)
        finally:
            ledger.close()   # close() 里带 flush，解绑/白名单都靠它落盘
            if mem is not None:
                mem.close()
        self._log("管理员命令 %s uid=%s -> %s"
                  % (adm[0], str(uid)[:10], "已回复" if out else "静默忽略"))
        return out

    def _mark_bound(self, uid):
        """领到码就当已绑定。成员表里没有这个人（比如老玩家在私聊领过）也补一条，
        否则 3 天规则会把他当成没绑定的人清掉。

        **整段都不许抛**：这一步只是记账，码已经发出去了，成员表炸掉
        也得让玩家看到码（云函数里代码目录只读，COS 没配好时就会抛）。
        """
        uid = str(uid or "").strip()
        if not uid:
            return
        mem = None
        try:
            mem = self._members()
            if mem.get(uid) is None:
                mem.add_member(uid, time.time())
                mem.get(uid)["state"] = "joined_late"
            mem.mark_bound(uid)
            mem.flush()
        except Exception as exc:
            self._log("标记已绑定失败 %s：%s" % (uid[:10], exc))
        finally:
            if mem is not None:
                try:
                    mem.close()
                except Exception:
                    pass

    def _issue(self, uid, hwid):
        """发码 + 落盘。账本在函数里存不住，所以每次都要读回来再写回去。

        走 bot.issue_for 而不是在这里再判一遍 get_by_hwid —— 它顺带会把
        「老记录里存的 union_openid」修正成现在的 member_openid，
        否则群成员事件永远对不上、老玩家会被清退出群。
        """
        ledger = self.ledger_factory()
        try:
            return self.bot.issue_for(uid, hwid, ledger)
        finally:
            ledger.close()   # close() 里带 flush

    # ────────────────────────── 发送 ──────────────────────────
    def token(self):
        now = time.time()
        if self._token and now < self._token_expire - 60:
            return self._token
        token, ttl = self.bot.get_access_token()
        self._token = token
        self._token_expire = now + ttl
        self._log("access_token 已刷新，%d 秒有效" % ttl)
        return token

    def _send_c2c(self, openid, content, msg_id):
        try:
            status, body = self.bot.send_c2c(self.token(), openid, content, msg_id)
        except Exception as exc:
            self._log("私聊回复异常：%s" % exc)
            return
        self._log("私聊回复 status=%s %s" % (status, "" if status < 400
                                            else json.dumps(body, ensure_ascii=False)[:160]))

    def _send_group(self, group_openid, content, msg_id):
        try:
            status, body = self.bot.send_group(self.token(), group_openid, content, msg_id)
        except Exception as exc:
            self._log("群回复异常：%s" % exc)
            return
        self._log("群回复 status=%s %s" % (status, "" if status < 400
                                           else json.dumps(body, ensure_ascii=False)[:160]))
