#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
package_dir="${script_dir:h}"
src_app="$package_dir/app/Codex Russian Dictation Hook.app"
src_script="$package_dir/src/codex_ru_dictation_hook.applescript"
dst_app="/Applications/Codex Russian Dictation Hook.app"
build_app="$package_dir/app/Codex Russian Dictation Hook.app"
plist="$HOME/Library/LaunchAgents/com.alex.codex-ru-dictation-hook.plist"
label="com.alex.codex-ru-dictation-hook"
domain="gui/$(id -u)"

if [[ ! -d "$src_app" ]]; then
  if [[ ! -f "$src_script" ]]; then
    echo "Cannot find app bundle or source script." >&2
    echo "Missing: $src_app" >&2
    echo "Missing: $src_script" >&2
    exit 1
  fi
  mkdir -p "$package_dir/app"
  osacompile -o "$build_app" "$src_script"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.alex.codex-ru-dictation-hook" "$build_app/Contents/Info.plist" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.alex.codex-ru-dictation-hook" "$build_app/Contents/Info.plist"
  codesign --force --deep --sign - "$build_app" >/dev/null 2>&1 || true
  src_app="$build_app"
fi

mkdir -p "$HOME/Library/LaunchAgents"

launchctl bootout "$domain" "$plist" 2>/dev/null || true
/usr/bin/pkill -f 'Codex Russian Dictation Hook.app/Contents/MacOS/applet' 2>/dev/null || true

rm -rf "$dst_app"
ditto "$src_app" "$dst_app"
xattr -dr com.apple.quarantine "$dst_app" 2>/dev/null || true
codesign --force --deep --sign - "$dst_app" >/dev/null 2>&1 || true

cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/open</string>
    <string>-g</string>
    <string>$dst_app</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
PLIST

launchctl bootstrap "$domain" "$plist"
open -R "$dst_app"
open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'

echo "Installed: $dst_app"
echo "LaunchAgent: $plist"
echo "Now add the app to Privacy & Security -> Accessibility."
