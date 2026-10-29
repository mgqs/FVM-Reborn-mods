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
                 verbose=True, secret_ok=True):
        self.app_id = (app_id or "").strip()
        self.bot = bot_module
        self.ledger_factory = ledger_factory
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

        if name == "C2C_MESSAGE_CREATE":
            uid = bot.uid_of(data)
            if not uid:
                return
            text = data.get("content", "")
            msg_id = data.get("id", "")
            self._log("私聊 %s %r" % (uid[:12], text[:30]))
            out = self._handle_text(uid, text)
            if out:
                self._send_c2c(uid, out, msg_id)
            return

        if name == "GROUP_AT_MESSAGE_CREATE":
            group_openid = data.get("group_openid", "")
            uid = bot.uid_of(data)
            text = data.get("content", "")
            msg_id = data.get("id", "")
            self._log("群@ %s group=%s %r"
                      % (uid[:10], str(group_openid)[:10], text[:40]))
            if not group_openid or not msg_id:
                self._log("跳过：缺 group_openid / msg_id")
                return
            if bot.ALLOW_GROUP_ISSUE:
                out = self._handle_text(uid, text)
                if out:
                    self._send_group(group_openid, out, msg_id)
                else:
                    self._log("忽略：没命中命令（需要 %s 加识别码）"
                              % " / ".join(bot.AUTH_CMDS))
            elif bot.parse_command(text):
                self._send_group(group_openid,
                                 bot.MSG_GROUP_HINT.format(cmd=bot.AUTH_COMMAND),
                                 msg_id)
            return

        self._log("事件 %s 不处理" % name)

    def _handle_text(self, uid, text):
        """把发码这件事接到 COS 账本上，其余逻辑全用 bot.py 的。"""
        bot = self.bot
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

    def _issue(self, uid, hwid):
        """发码 + 落盘。账本在函数里存不住，所以每次都要读回来再写回去。"""
        ledger = self.ledger_factory()
        try:
            row = ledger.get_by_hwid(hwid)
            if row:
                return row[3], False
            return self.bot.qq_auth.issue_for(uid, hwid, ledger)
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
