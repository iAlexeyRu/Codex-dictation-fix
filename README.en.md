# Codex Russian Dictation Hook

Small macOS workaround for OpenAI Codex Desktop global dictation when the current keyboard layout is Russian.

Russian documentation is available in [README.md](README.md).

## Problem

Codex Desktop dictation can transcribe speech correctly, but with the Russian keyboard layout selected it may fail to paste the recognized text into the focused field.

Root cause: the current Codex app appears to simulate paste using AppleScript similar to:

```applescript
tell application "System Events" to keystroke "v" using command down
```

That is keyboard-layout dependent. Under the Russian layout, `"v"` is not the physical `V` key, so macOS does not perform `Cmd+V`.

The layout-independent command is:

```applescript
tell application "System Events" to key code 9 using command down
```

Upstream issue: https://github.com/openai/codex/issues/19710

## What This Hook Does

The helper runs in the background and watches:

```text
~/.codex/transcription-history.jsonl
```

When Codex adds a new dictation transcript and briefly places that transcript in the clipboard, the helper checks whether the active input source is Russian. If it is, the helper sends physical `Cmd+V` via `key code 9`.

It does not modify `Codex.app`.

The helper is installed as a background app (`LSUIElement=true`), so it does not appear in the Dock or Cmd-Tab after launch.

## Install

Download the latest release:

https://github.com/iAlexeyRu/Codex-dictation-fix/releases/latest

Then run:

```zsh
unzip CodexRussianDictationHook-1.0.2.zip
cd CodexRussianDictationHook
./scripts/install.sh
```

After installation, add and enable:

```text
/Applications/Codex Russian Dictation Hook.app
```

in:

```text
Privacy & Security -> Accessibility
```

If the app is already listed, remove it and add it again.

## Install From Source

```zsh
git clone https://github.com/iAlexeyRu/Codex-dictation-fix.git
cd Codex-dictation-fix
./scripts/install.sh
```

When installing from source, the installer builds the helper app with `osacompile`.

## Test

1. Switch macOS keyboard layout to Russian.
2. Open TextEdit, Notes, or another editable text field.
3. Click into the text field so the insertion cursor is active.
4. Use Codex global dictation.

Expected result: the transcript is pasted into the text field.

## Uninstall

```zsh
./scripts/uninstall.sh
```

Then remove `Codex Russian Dictation Hook.app` from macOS Accessibility settings.

## Logs

```text
~/.codex/log/codex_ru_dictation_hook_app.log
```

If the log says that keystrokes are not allowed, grant Accessibility permission to `Codex Russian Dictation Hook.app`.

## Repository Layout

- `README.md` - Russian documentation
- `README.en.md` - English documentation
- `CHANGELOG.md` - changelog
- `src/codex_ru_dictation_hook.applescript` - hook source
- `scripts/install.sh` - installs the app and LaunchAgent
- `scripts/uninstall.sh` - stops and removes the app and LaunchAgent
- `dist/CodexRussianDictationHook-1.0.2.zip` - ready-to-install release archive
