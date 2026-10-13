#!/usr/bin/python3
"""Two-stage wallpaper picker: category, then image-only thumbnails."""
import hashlib
import json
import os
import shutil
import signal
import subprocess
from pathlib import Path

import gi
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf, GLib

ROOT = Path.home() / "Pictures/Wallpaper"
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "wofi"
CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "wofi/wallpaper"
RUNTIME = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / f"wofi-wallpaper-{os.getuid()}"
TYPES = {
    "图片": {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tif", ".tiff", ".avif"},
    "动图": {".gif"},
    "视频": {".mp4", ".webm", ".mkv", ".mov", ".m4v"},
}


def notify(message):
    subprocess.run(["notify-send", "壁纸", message], check=False)


def menu(entries, prompt, gallery=False):
    command = [
        "wofi", "--show", "dmenu", "--prompt", prompt,
        "--cache-file", "/dev/null", "--no-custom-entry",
        "--define", "allow_markup=false",
        "--define", "dmenu-parse_action=false",
        "--define", "dmenu-print_line_num=false",
    ]
    if gallery:
        command += [
            "--style", str(CONFIG / "css/wallpaper.css"),
            "--width", "820", "--height", "540", "--columns", "3",
            "--hide-search", "--allow-images", "--define", "image_size=220",
        ]
    else:
        command += ["--width", "420", "--height", "240", "--columns", "1",
                    "--define", "allow_images=false"]
    result = subprocess.run(command, input="\n".join(entries) + "\n",
                            text=True, stdout=subprocess.PIPE)
    if result.returncode != 0:
        return None
    selected = result.stdout.rstrip("\n")
    return selected if selected in entries else None


def thumbnail(path, video=False):
    stat = path.stat()
    key = hashlib.sha256(
        f"v1:{path}:{stat.st_mtime_ns}:{stat.st_size}".encode()
    ).hexdigest()
    target = CACHE / f"{key}.png"
    if target.exists():
        return target
    temporary = CACHE / f"{key}.{os.getpid()}.tmp.png"
    try:
        if video:
            subprocess.run([
                "ffmpeg", "-nostdin", "-loglevel", "error", "-y",
                "-i", str(path), "-frames:v", "1",
                "-vf", "scale=220:140:force_original_aspect_ratio=decrease,"
                "pad=220:140:(ow-iw)/2:(oh-ih)/2:color=0x202020",
                str(temporary),
            ], check=True, timeout=30)
        else:
            image = GdkPixbuf.Pixbuf.new_from_file_at_scale(str(path), 220, 140, True)
            canvas = GdkPixbuf.Pixbuf.new(GdkPixbuf.Colorspace.RGB, True, 8, 220, 140)
            canvas.fill(0x202020FF)
            width, height = image.get_width(), image.get_height()
            image.copy_area(0, 0, width, height, canvas,
                            (220 - width) // 2, (140 - height) // 2)
            canvas.savev(str(temporary), "png", [], [])
        temporary.replace(target)
        return target
    finally:
        temporary.unlink(missing_ok=True)


def process_identity(pid):
    # Linux start time prevents a recycled PID from matching an old player.
    return Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()[19]


def stop_video():
    state = RUNTIME / "video.json"
    if not state.exists():
        return
    try:
        data = json.loads(state.read_text())
        pid = int(data["pid"])
        executable = Path(f"/proc/{pid}/exe").resolve().name
        if executable == "mpvpaper" and process_identity(pid) == data["start"]:
            os.kill(pid, signal.SIGTERM)
    except (OSError, ValueError, KeyError, IndexError):
        pass
    state.unlink(missing_ok=True)


def apply_wallpaper(path, category):
    if category == "视频":
        if not shutil.which("mpvpaper"):
            raise RuntimeError("视频壁纸需要安装 mpvpaper")
        stop_video()
        log = RUNTIME / "mpvpaper.log"
        with log.open("wb") as output:
            player = subprocess.Popen([
                "mpvpaper", "-o",
                "no-audio loop-file=inf hwdec=auto-safe panscan=1",
                "ALL", str(path),
            ], stdin=subprocess.DEVNULL, stdout=output, stderr=output,
               start_new_session=True)
        try:
            code = player.wait(timeout=0.5)
        except subprocess.TimeoutExpired:
            (RUNTIME / "video.json").write_text(json.dumps({
                "pid": player.pid, "start": process_identity(player.pid),
            }))
        else:
            raise RuntimeError(f"视频壁纸启动失败（退出码 {code}），详情：{log}")
    else:
        # Only stop our video after awww successfully accepts the new wallpaper.
        subprocess.run([
            "awww", "img", str(path), "--transition-type", "grow",
            "--transition-duration", "1",
        ], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stop_video()


def main():
    if not ROOT.is_dir():
        notify(f"壁纸目录不存在：{ROOT}")
        return
    category = menu(list(TYPES), "壁纸类型")
    if category is None:
        return
    if category == "视频" and not all(shutil.which(c) for c in ("ffmpeg", "mpvpaper")):
        notify("视频壁纸需要 ffmpeg 和 mpvpaper")
        return
    CACHE.mkdir(parents=True, exist_ok=True)
    RUNTIME.mkdir(mode=0o700, parents=True, exist_ok=True)
    paths = sorted((p for p in ROOT.rglob("*")
                    if p.is_file() and p.suffix.lower() in TYPES[category]),
                   key=lambda p: str(p).casefold())
    if not paths:
        notify(f"{ROOT} 中没有{category}文件")
        return
    choices = {}
    skipped = 0
    for path in paths:
        try:
            # Keep the full input as the action; never map by basename.
            choices[f"img:{thumbnail(path, category == '视频')}"] = path
        except (OSError, GLib.Error, subprocess.SubprocessError):
            skipped += 1
    if skipped:
        notify(f"有 {skipped} 个文件无法生成预览，已跳过")
    if not choices:
        notify("没有可以预览的壁纸")
        return
    selected = menu(list(choices), category, gallery=True)
    if selected is not None:
        apply_wallpaper(choices[selected], category)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        detail = getattr(error, "stderr", None) or str(error)
        notify(f"壁纸切换失败：{detail[:300]}")
