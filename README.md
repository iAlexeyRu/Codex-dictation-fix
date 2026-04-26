# Codex Russian Dictation Hook

Small macOS workaround for OpenAI Codex desktop global dictation when the current keyboard layout is Russian.

## Problem

Codex desktop dictation can transcribe speech correctly, but with the Russian keyboard layout selected it may fail to paste the recognized text into the focused field.

Root cause: the current Codex app simulates paste using AppleScript similar to:

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

The helper runs in the background and watches `~/.codex/transcription-history.jsonl`.

When Codex adds a new dictation transcript and briefly places that transcript in the clipboard, the helper checks whether the active input source is Russian. If it is, the helper sends physical `Cmd+V` via `key code 9`.

It does not modify Codex.app.

The helper is installed as a background app (`LSUIElement=true`), so it does not appear in the Dock or Cmd-Tab after launch.

## Install

From a release zip:

1. Unzip the package.
2. Open Terminal in the package folder.
3. Run:

```zsh
./scripts/install.sh
```

4. macOS System Settings will open. Add and enable:

```text
/Applications/Codex Russian Dictation Hook.app
```

in:

```text
Privacy & Security -> Accessibility
```

If the app is already listed, remove it and add it again.

From a git clone:

```zsh
git clone https://github.com/iAlexeyRu/Codex-dictation-fix.git
cd Codex-dictation-fix
./scripts/install.sh
```

When installing from source, the script builds the helper app with `osacompile`.

## Test

1. Switch macOS keyboard layout to Russian.
2. Open TextEdit or Notes.
3. Click into the document so the insertion cursor is active.
4. Use Codex global dictation.

Expected: the transcript appears in the text field.

## Uninstall

```zsh
./scripts/uninstall.sh
```

Then remove `Codex Russian Dictation Hook.app` from macOS Accessibility settings.

## Files

- `app/Codex Russian Dictation Hook.app` - compiled helper app, present in release zip
- `src/codex_ru_dictation_hook.applescript` - source
- `scripts/install.sh` - installs app and LaunchAgent
- `scripts/uninstall.sh` - stops and removes app and LaunchAgent
- `dist/CodexRussianDictationHook-1.0.zip` - ready-to-send install package, present in the repository
