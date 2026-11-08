# -*- coding: utf-8 -*-
"""
从 GD Studio 音乐 API 抓取 VIP 曲目并转成 BOSS 随机音乐曲库需要的 .ogg。

用法：
    python tools/fetch_vip_songs.py                 # 只搜索+匹配，显示结果
    python tools/fetch_vip_songs.py --apply         # 真下载并转码
    python tools/fetch_vip_songs.py --apply --br 320

源目录默认 D:\\CloudMusic\\VipSongsDownload（读文件名当歌名用），
输出到 %LOCALAPPDATA%\\FVM_Reborn_makk\\boss_music。
"""
import os
import sys
import json
import time
import subprocess
import urllib.parse
import urllib.request

API = "https://music-api.gdstudio.xyz/api.php"
UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/122.0 Safari/537.36")
SRC = r"D:\CloudMusic\VipSongsDownload"
TMP = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_vip_tmp")

FFMPEG_CANDIDATES = [
    r"C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23\bin\ffmpeg\windows\ffmpeg.exe",
]


def find_ffmpeg():
    for p in FFMPEG_CANDIDATES:
        if os.path.exists(p):
            return p
    import glob
    for p in glob.glob(r"C:\ProgramData\GameMakerStudio2*\Cache\runtimes\*\bin\ffmpeg\windows\ffmpeg.exe"):
        return p
    raise SystemExit("找不到 ffmpeg.exe")


def get_json(url, tries=3):
    last = None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=20) as r:
                return json.loads(r.read().decode("utf-8", "replace"))
        except Exception as e:
            last = e
            time.sleep(1.5 * (i + 1))
    raise last


def search(name):
    q = urllib.parse.quote(name)
    url = "%s?types=search&source=netease&name=%s&count=15&pages=1" % (API, q)
    r = get_json(url)
    return r if isinstance(r, list) else []


def norm(s):
    return "".join(ch for ch in (s or "").lower() if ch.isalnum())


def pick(results, artist, title):
    """按歌手名匹配度挑一个结果；匹配不到就取第一条。"""
    if not results:
        return None
    artists = [norm(x) for x in artist.replace("，", ",").replace("/", ",").split(",") if norm(x)]
    best, best_score = None, -1
    for idx, it in enumerate(results):
        r_art = norm(" ".join(it.get("artist") or []))
        r_name = norm(it.get("name"))
        score = 0
        for a in artists:
            if a and a in r_art:
                score += 10
                break
        if norm(title) == r_name:
            score += 5
        elif norm(title) in r_name:
            score += 2
        if it.get("url_id"):
            score += 1
        score -= idx * 0.1          # 靠前的优先
        if score > best_score:
            best, best_score = it, score
    return best


def get_url(song_id, br):
    url = "%s?types=url&source=netease&id=%s&br=%s" % (API, song_id, br)
    r = get_json(url)
    if isinstance(r, dict):
        return r.get("url"), r.get("br"), r.get("size")
    return None, None, None


def download(url, dst):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=120) as r, open(dst, "wb") as f:
        total = 0
        while True:
            chunk = r.read(262144)
            if not chunk:
                break
            f.write(chunk)
            total += len(chunk)
    return total


def safe_name(s):
    bad = '\\/:*?"<>|'
    for ch in bad:
        s = s.replace(ch, "_")
    return s.strip().strip(".")


def main():
    apply = "--apply" in sys.argv
    br = "320"
    for i, a in enumerate(sys.argv):
        if a == "--br" and i + 1 < len(sys.argv):
            br = sys.argv[i + 1]

    out = os.path.join(os.environ.get("LOCALAPPDATA", ""), "FVM_Reborn_makk", "boss_music")
    if apply:
        os.makedirs(out, exist_ok=True)
        os.makedirs(TMP, exist_ok=True)
        ff = find_ffmpeg()

    files = sorted([x for x in os.listdir(SRC) if x.lower().endswith(".ncm")])
    print("源目录 :", SRC)
    print("输出   :", out)
    print("曲目数 :", len(files), " 音质:", br, "kbps")
    print()

    ok = fail = skip = 0
    for i, fn in enumerate(files, 1):
        base = os.path.splitext(fn)[0]
        if " - " in base:
            artist, title = base.split(" - ", 1)
        else:
            artist, title = "", base

        dst_ogg = os.path.join(out, safe_name(base) + ".ogg")
        if os.path.exists(dst_ogg):
            print("  [%2d/%d] SKIP %-46s 已存在" % (i, len(files), base))
            skip += 1
            continue

        try:
            res = search(title if not artist else title)
            hit = pick(res, artist, title)
            if not hit:
                print("  [%2d/%d] FAIL %-46s 搜不到" % (i, len(files), base))
                fail += 1
                continue
            sid = hit.get("url_id") or hit.get("id")
            hit_txt = "%s - %s [%s]" % ("/".join(hit.get("artist") or []), hit.get("name"), sid)
            url, real_br, size = get_url(sid, br)
            if not url:
                print("  [%2d/%d] FAIL %-46s 无直链（可能仍是版权限制）%s" % (i, len(files), base, hit_txt))
                fail += 1
                continue

            if not apply:
                print("  [%2d/%d] HIT  %-46s -> %s  %sk  %.1fMB" % (
                    i, len(files), base, hit_txt, real_br, (size or 0) / 1024 / 1024))
                ok += 1
                continue

            tmp_mp3 = os.path.join(TMP, "%02d" % i + ".mp3")
            got = download(url, tmp_mp3)
            cmd = [ff, "-y", "-loglevel", "error", "-i", tmp_mp3, "-vn",
                   "-c:a", "libvorbis", "-q:a", "6", dst_ogg]
            r = subprocess.run(cmd, capture_output=True, text=True,
                               encoding="utf-8", errors="replace")
            if r.returncode == 0 and os.path.exists(dst_ogg):
                mb = os.path.getsize(dst_ogg) / 1024 / 1024
                print("  [%2d/%d] OK   %-46s -> %.1f MB  (源 %.1f MB, %sk)" % (
                    i, len(files), base, mb, got / 1024 / 1024, real_br))
                ok += 1
            else:
                err = (r.stderr or "").strip().replace("\n", " ")
                print("  [%2d/%d] FAIL %-46s 转码失败 %s" % (i, len(files), base, err[:100]))
                fail += 1
            try:
                os.remove(tmp_mp3)
            except OSError:
                pass
        except Exception as e:
            print("  [%2d/%d] FAIL %-46s %s" % (i, len(files), base, str(e)[:100]))
            fail += 1

    print("\n完成：%s %d，失败 %d，跳过 %d" % ("成功" if apply else "可下载", ok, fail, skip))
    if not apply:
        print("确认后加 --apply 真下载。")
    else:
        print("进游戏 → 设置 → 音频设置，打开「BOSS 随机音乐」。")
        try:
            os.rmdir(TMP)
        except OSError:
            pass


if __name__ == "__main__":
    main()
