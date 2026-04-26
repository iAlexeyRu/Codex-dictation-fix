# Codex Russian Dictation Hook

## English

English documentation is available here: [README.en.md](README.en.md).

## Что это

Небольшой macOS-хук для OpenAI Codex Desktop. Он исправляет проблему, когда глобальная диктовка Codex распознает речь, но не вставляет текст в активное поле при включенной русской раскладке клавиатуры.

Хук не меняет `Codex.app` и не патчит бинарники. Он работает рядом с Codex как фоновое приложение.

Upstream issue в OpenAI Codex: https://github.com/openai/codex/issues/19710

## Проблема

Codex Desktop после диктовки временно кладет распознанный текст в clipboard и вызывает paste через AppleScript примерно так:

```applescript
tell application "System Events" to keystroke "v" using command down
```

На английской раскладке это работает как `Cmd+V`. На русской раскладке `"v"` не является физической клавишей `V`, поэтому вставка не происходит.

Раскладко-независимый вариант:

```applescript
tell application "System Events" to key code 9 using command down
```

`key code 9` - это физическая клавиша `V` на macOS, поэтому `Command + key code 9` срабатывает как paste независимо от текущей раскладки.

## Как работает хук

Фоновое приложение следит за файлом:

```text
~/.codex/transcription-history.jsonl
```

Когда Codex добавляет новый результат диктовки и на короткое время кладет этот текст в clipboard, хук проверяет текущую раскладку. Если включена русская раскладка, он отправляет физический `Cmd+V` через `key code 9`.

Приложение устанавливается как background app (`LSUIElement=true`), поэтому после запуска не отображается в Dock и Cmd-Tab.

## Установка

Самый простой вариант - скачать готовый архив из релиза:

https://github.com/iAlexeyRu/Codex-dictation-fix/releases/latest

Затем:

```zsh
unzip CodexRussianDictationHook-1.0.2.zip
cd CodexRussianDictationHook
./scripts/install.sh
```

После установки macOS откроет настройки. Нужно добавить и включить:

```text
/Applications/Codex Russian Dictation Hook.app
```

в разделе:

```text
Privacy & Security -> Accessibility
```

Если приложение уже есть в списке, удалите его и добавьте заново. Это важно после обновлений, потому что macOS может сбросить доверие к переподписанному `.app`.

## Установка из исходников

```zsh
git clone https://github.com/iAlexeyRu/Codex-dictation-fix.git
cd Codex-dictation-fix
./scripts/install.sh
```

Если готового `.app` нет, installer сам соберет его из `src/codex_ru_dictation_hook.applescript` через `osacompile`.

## Проверка

1. Переключите macOS на русскую раскладку.
2. Откройте TextEdit, Notes или любое поле ввода.
3. Кликните в текстовое поле, чтобы появился активный курсор.
4. Запустите глобальную диктовку Codex.

Ожидаемый результат: распознанный текст вставляется в поле ввода.

## Удаление

```zsh
./scripts/uninstall.sh
```

После этого можно удалить `Codex Russian Dictation Hook.app` из `Privacy & Security -> Accessibility`.

## Диагностика

Лог хука:

```text
~/.codex/log/codex_ru_dictation_hook_app.log
```

Если в логе есть ошибка вида:

```text
Отправка нажатий клавиш для «Codex Russian Dictation Hook» не разрешена
```

значит macOS не выдала Accessibility-доступ. Добавьте приложение в `Privacy & Security -> Accessibility`.

## Состав release zip

- `src/codex_ru_dictation_hook.applescript` - исходник хука
- `scripts/install.sh` - установка `.app` и LaunchAgent
- `scripts/uninstall.sh` - остановка и удаление
- `app/Codex Russian Dictation Hook.app` - готовое приложение внутри release zip

## Состав репозитория

- `README.md` - русская документация
- `README.en.md` - английская документация
- `CHANGELOG.md` - история изменений
- `src/codex_ru_dictation_hook.applescript` - исходник хука
- `scripts/install.sh` - установка `.app` и LaunchAgent
- `scripts/uninstall.sh` - остановка и удаление
- `dist/CodexRussianDictationHook-1.0.2.zip` - готовый архив для установки
