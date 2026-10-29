#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""打包成腾讯云函数可以直接上传的 zip。

    python build.py

产物：bots/qq_auth_bot/scf-qqauth.zip

白名单复制，不用通配符——避免把 `qq_auth.db`（账本）、
`auth_secret.txt`（签名密钥）这类东西顺手上传到云上。

密钥为什么不进包
----------------
`auth_secret.txt` 和 `app_secret` 都不打进去，改由函数的**环境变量**提供。
理由是：代码包会被下载、备份、留在构建历史里，密钥一旦进去就等于长期暴露；
环境变量可以随时改，改完不用重新上传代码。
"""

import json
import os
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
BOT_DIR = os.path.abspath(os.path.join(HERE, ".."))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
TOOLS = os.path.join(ROOT, "tools")

OUT = os.path.abspath(os.path.join(HERE, "..", "scf-qqauth.zip"))

# (源路径, zip 内的名字)
FILES = [
    (os.path.join(HERE, "main.py"), "main.py"),
    (os.path.join(HERE, "webhook.py"), "webhook.py"),
    (os.path.join(HERE, "store.py"), "store.py"),
    (os.path.join(HERE, "ed25519_ref.py"), "ed25519_ref.py"),
    (os.path.join(BOT_DIR, "bot.py"), "bot.py"),
    (os.path.join(TOOLS, "qq_auth.py"), "qq_auth.py"),
    (os.path.join(TOOLS, "codes_pool.txt"), "codes_pool.txt"),
]


def build_config():
    """复制 config.json，但把 app_secret 挖掉（走环境变量）。"""
    src = os.path.join(BOT_DIR, "config.json")
    if not os.path.exists(src):
        print("⚠️  没有 config.json，用默认命令词（#授权 / 查码）")
        return {"auth_command": "/授权", "allow_group_issue": True}
    with open(src, "r", encoding="utf-8") as fh:
        cfg = json.load(fh)
    if cfg.pop("app_secret", None):
        print("  · 已从 config.json 移除 app_secret（改由环境变量 QQ_APP_SECRET 提供）")
    cfg.pop("sandbox", None)
    return cfg


def main():
    print("检查源文件…")
    missing = []
    for path, name in FILES:
        if not os.path.exists(path):
            missing.append("%s（应为 %s）" % (name, path))
    if missing:
        print("✗ 缺文件：")
        for m in missing:
            print("   · %s" % m)
        return 1

    total = sum(os.path.getsize(p) for p, _ in FILES)
    print("  待打包 %d 个文件，%.1f KB" % (len(FILES), total / 1024.0))

    pool = open(os.path.join(TOOLS, "codes_pool.txt"), encoding="utf-8").read()
    ids = [line.strip() for line in pool.splitlines()
           if line.strip() and not line.strip().startswith("#")]
    print("  码池 %d 个" % len(ids))
    if not ids:
        print("✗ 码池是空的，先跑 python tools/qq_auth.py poolgen 500")
        return 1

    if os.path.exists(OUT):
        os.remove(OUT)

    print("打包 → %s" % OUT)
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for path, name in FILES:
            zf.write(path, name)
            print("  + %-16s %6.1f KB" % (name, os.path.getsize(path) / 1024.0))
        cfg = build_config()
        zf.writestr("config.json", json.dumps(cfg, ensure_ascii=False, indent=2))
        print("  + %-16s %6.1f KB" % ("config.json", len(json.dumps(cfg)) / 1024.0))

    size = os.path.getsize(OUT)
    print("\n✓ 完成，%.1f KB" % (size / 1024.0))
    if size > 40 * 1024 * 1024:
        print("⚠️  超过 40 MB，SCF 控制台直传可能失败，改走上传到 COS 再引用")

    print("""
下一步（详见 README.md）：
  1. 腾讯云 → 云函数 SCF → 新建函数（Python 3.9+，选「事件函数」）
  2. 上传这个 zip，执行方法填 main.main_handler
  3. 函数配置 → 环境变量，填 QQ_APP_ID / QQ_APP_SECRET / AUTH_SECRET / COS_*
  4. 函数配置 → 触发器/函数 URL，开一个公网 HTTPS 地址
  5. 开放平台 → 开发设置 → 事件订阅与回调地址 → 切到 Webhook，填上面那个地址
  6. 到云函数「日志」里应看到「握手校验已应答」，页面提示保存成功
""")
    return 0


if __name__ == "__main__":
    sys.exit(main())
