BOT = r"D:\gameProject\FVM-Reborn-mod\bots\qq_auth_bot\bot.py"
WH  = r"D:\gameProject\FVM-Reborn-mod\bots\qq_auth_bot\scf\webhook.py"
BS = chr(92)

raw = open(BOT, "rb").read(); crlf = b"\r\n" in raw
t = raw.decode("utf-8").replace("\r\n", "\n")

old_strip = 'def strip_mention(text):\n    """去掉 <@!123> / @机器人 这类前缀，再取命令词。"""\n'
i = t.index(old_strip)
j = t.index("\ndef ", i)
old_block = t[i:j]

new_block = (
'def strip_mention(text):\n'
'    """去掉 <@!123> / <@123> / 明文 @机器人 这类前缀，再取命令词。\n'
'\n'
'    官方 QQ 剥掉 @ 之后推来的 content 可能只剩 " 513E7579"，\n'
'    有些客户端又会把 " @小Makk /授权 513E7579" 整串原样送上来；\n'
'    三种形态都要认得出，否则玩家 @ 了机器人却一点反应都没有。\n'
'    """\n'
'    t = text or ""\n'
'    while True:\n'
'        s = t.find("<@")\n'
'        if s < 0:\n'
'            break\n'
'        e = t.find(">", s)\n'
'        if e < 0:\n'
'            break\n'
'        t = t[:s] + t[e + 1:]\n'
'    t = t.replace("<@", "").replace(">", "").strip()\n'
'\n'
'    while t[:1] in ("@", "\uff20"):\n'
'        rest = t[1:].lstrip()\n'
'        k = 0\n'
'        while k < len(rest) and rest[k] not in (" ", "\t", "\u3000", "/", "#", "\uff0f", "\uff03"):\n'
'            k += 1\n'
'        head = rest[:k]\n'
'        tail = rest[k:].lstrip()\n'
'        if not tail and _looks_like_hwid(head):\n'
'            t = rest\n'
'            break\n'
'        t = tail\n'
'    return t.strip()\n'
'\n'
'\n'
'def _looks_like_hwid(token):\n'
'    """`1A2B-3C4D` / `1a2b3c4d` 这种是不是识别码。"""\n'
'    s = "".join(ch for ch in str(token or "") if ch not in "- _"\n'.replace(chr(92)+'n', chr(92)+'n')
)
open(r"D:\gameProject\_tmp_block.txt","w",encoding="utf-8").write("ok")
print("placeholder")
