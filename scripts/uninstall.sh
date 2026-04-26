#!/bin/zsh
set -euo pipefail

plist="$HOME/Library/LaunchAgents/com.alex.codex-ru-dictation-hook.plist"
dst_app="/Applications/Codex Russian Dictation Hook.app"
domain="gui/$(id -u)"

launchctl bootout "$domain" "$plist" 2>/dev/null || true
/usr/bin/pkill -f 'Codex Russian Dictation Hook.app/Contents/MacOS/applet' 2>/dev/null || true
rm -f "$plist"
rm -rf "$dst_app"

echo "Codex Russian Dictation Hook удален."
echo "Если приложение осталось в Privacy & Security -> Accessibility, удалите его вручную."
