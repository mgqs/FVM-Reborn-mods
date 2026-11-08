# -*- coding: utf-8 -*-
"""
boss_music_import.py —— 把本地音乐转成 BOSS 随机音乐曲库需要的 .ogg

背景：GM 的 audio_create_stream() 只吃 .ogg，网易云下载的是 mp3/flac，必须转码。

用法（项目根目录）：
    # 1) 先看看会转什么（不写文件）
    python tools\\boss_music_import.py "D:\\CloudMusic" --list

    # 2) 真转（输出到 %LOCALAPPDATA%\\FVM_Reborn_makk\\boss_music）
    python tools\\boss_music_import.py "D:\\CloudMusic" --apply

    # 可以给多个源目录
    python tools\\boss_music_import.py "D:\\CloudMusic" "E:\\网易云音乐" --apply

    # 指定音质（0~10，默认 6 ≈ 128kbps；10 最高但文件大）
    python tools\\boss_music_import.py "D:\\CloudMusic" --apply --quality 8

ffmpeg 会自动从 GameMaker runtime 目录里找，找不到才用 PATH 里的。
"""
import argparse
import glob
import os
import re
import shutil
import subprocess
import sys

AUDIO_EXT = (".mp3", ".flac", ".m4a", ".wav", ".aac", ".wma", ".ape")


def find_ffmpeg():
    """优先用 GameMaker runtime 自带的 ffmpeg，避免依赖系统 PATH。"""
    pats = [
        r"C:\ProgramData\GameMakerStudio2*\Cache\runtimes\*\bin\ffmpeg\windows\ffmpeg.exe",
        r"C:\ProgramData\GameMakerStudio2*\Cache\runtimes\*\bin\ffmpeg\ffmpeg.exe",
    ]
    for p in pats:
        hits = sorted(glob.glob(p))
        if hits:
            return hits[-1]
    return shutil.which("ffmpeg")


def safe_name(name):
    """去掉 Windows 非法字符，给文件名留出余量。"""
    name = re.sub(r'[\\/:*?"<>|]', "_", name)
    name = name.strip().strip(".")
    return name[:100] or "track"


def collect(dirs):
    files = []
    for d in dirs:
        if not os.path.isdir(d):
            print("跳过（不是目录）:", d)
            continue
        for cur, _, names in os.walk(d):
            for n in names:
                if n.lower().endswith(AUDIO_EXT):
                    files.append(os.path.join(cur, n))
    return sorted(files)


def target_dir():
    base = os.environ.get("LOCALAPPDATA")
    if not base:
        print("找不到 %LOCALAPPDATA%")
        sys.exit(1)
    return os.path.join(base, "FVM_Reborn_makk", "boss_music")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("dirs", nargs="+", help="音乐所在目录（可多个）")
    ap.add_argument("--apply", action="store_true", help="真的转码；不给就只列清单")
    ap.add_argument("--quality", default="6", help="ogg 音质 0~10，默认 6")
    ap.add_argument("--list", action="store_true", help="只列清单（等同默认行为）")
    args = ap.parse_args()

    ff = find_ffmpeg()
    if not ff:
        print("找不到 ffmpeg。GameMaker runtime 目录里应该有，或自行装一个放进 PATH。")
        sys.exit(1)

    src = collect(args.dirs)
    if not src:
        print("这些目录里没有找到音频文件:", args.dirs)
        print("支持的扩展名:", ", ".join(AUDIO_EXT))
        return

    out = target_dir()
    print("ffmpeg :", ff)
    print("输出到 :", out)
    print("发现 %d 个音频文件\n" % len(src))

    if not args.apply:
        for i, f in enumerate(src, 1):
            print("  %2d. %s" % (i, os.path.basename(f)))
        print("\n这是清单预览。确认无误后加 --apply 真转。")
        return

    os.makedirs(out, exist_ok=True)
    ok = fail = 0
    for i, f in enumerate(src, 1):
        base = safe_name(os.path.splitext(os.path.basename(f))[0])
        dst = os.path.join(out, base + ".ogg")
        if os.path.exists(dst):
            print("  [%d/%d] SKIP %-45s 已存在" % (i, len(src), base))
            ok += 1
            continue
        n = 2
        while os.path.exists(dst):
            dst = os.path.join(out, "%s_%d.ogg" % (base, n))
            n += 1
        # -vn：丢掉内嵌封面。mp3 里的 APIC 在 ffmpeg 眼里是 mjpeg 视频流，
        # 输出到 ogg 容器会要求 theora 编码器，而 GM 自带 ffmpeg 未编译 theora，
        # 报 "Automatic encoder selection failed / Encoder not found"。
        cmd = [ff, "-y", "-loglevel", "error", "-i", f, "-vn",
               "-c:a", "libvorbis", "-q:a", str(args.quality), dst]
        r = subprocess.run(cmd, capture_output=True, text=True,
                           encoding="utf-8", errors="replace")
        if r.returncode == 0 and os.path.exists(dst):
            size_mb = os.path.getsize(dst) / 1024 / 1024
            print("  [%d/%d] OK   %-45s -> %.1f MB" % (i, len(src), base, size_mb))
            ok += 1
        else:
            err = (r.stderr or "").strip().replace("\n", " ")
            print("  [%d/%d] FAIL %-45s %s" % (i, len(src), base, err[:120]))
            fail += 1

    print("\n完成：成功 %d，失败 %d" % (ok, fail))
    print("进游戏 → 设置 → 音频设置，打开「BOSS 随机音乐」即可。")


if __name__ == "__main__":
    main()
