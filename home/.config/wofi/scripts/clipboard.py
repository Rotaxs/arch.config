#!/usr/bin/python3
import os
import subprocess
import tempfile
from pathlib import Path

import gi
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf, GLib


def decode(item_id):
    return subprocess.check_output(["cliphist", "decode", item_id])


def main():
    history = subprocess.check_output(["cliphist", "list"])
    # 显示最近 100 条，避免大量图片拖慢菜单。
    records = history.decode("utf-8", errors="replace").splitlines()[:100]
    if not records:
        return

    # 临时图片在菜单关闭后自动清理。
    with tempfile.TemporaryDirectory(
        prefix="wofi-clipboard-",
        dir=os.environ.get("XDG_RUNTIME_DIR") or None,
    ) as directory:
        entries = []
        item_ids = []

        for record in records:
            item_id, separator, preview = record.partition("\t")
            if not separator or not item_id.isdigit():
                continue

            # 防止普通剪贴板文字被解释成图片指令。
            label = preview.replace('img:', 'img：')
            entry = label

            if preview.startswith("[[ binary data "):
                original = Path(directory) / f"{item_id}.original"
                thumbnail = Path(directory) / f"{item_id}.png"
                try:
                    original.write_bytes(decode(item_id))
                    image = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                        str(original), 96, 96, True
                    )
                    image.savev(str(thumbnail), "png", [], [])
                    entry = f"img:{thumbnail}:text:图片"
                except (subprocess.CalledProcessError, GLib.Error):
                    # 无法预览时仍显示条目，可以选择并复制。
                    pass

            entries.append(entry)
            item_ids.append(item_id)

        if not entries:
            return

        result = subprocess.run(
            [
                "wofi", "--show", "dmenu",
                "--style", str(Path(os.environ.get(
                    "XDG_CONFIG_HOME", Path.home() / ".config"
                )) / "wofi/clipboard.css"),
                "--prompt", "剪贴板",
                "--allow-images",
                "--width", "640",
                "--height", "560",
                "--cache-file", "/dev/null",
                "--define", "image_size=96",
                "--define", "allow_markup=false",
                "--define", "parse_search=true",
                "--define", "line_wrap=word_char",
                "--define", "halign=fill",
                "--define", "content_halign=fill",
                "--define", "dmenu-parse_action=true",
                "--define", "dmenu-print_line_num=true",
                "--no-custom-entry",
            ],
            input="\n".join(entries) + "\n",
            text=True,
            stdout=subprocess.PIPE,
        )

        # Esc 或关闭菜单：保留当前剪贴板。
        if result.returncode != 0 or not result.stdout:
            return

        # wofi 返回原始输入行的零起始索引；不依赖显示文本或排序。
        selected = result.stdout.strip()
        if not selected.isdigit():
            return
        index = int(selected)
        if index >= len(item_ids):
            return
        item_id = item_ids[index]

        # 复制原始数据，而非缩略图；保留文本换行和图片内容。
        content = decode(item_id)
        subprocess.run(["wl-copy"], input=content, check=True)


if __name__ == "__main__":
    main()
