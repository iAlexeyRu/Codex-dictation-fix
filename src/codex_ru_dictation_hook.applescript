property lastLine : ""
property lastPastedId : ""
property historyPath : ""
property logPath : ""

on run
  set historyPath to (POSIX path of (path to home folder)) & ".codex/transcription-history.jsonl"
  set logPath to (POSIX path of (path to home folder)) & ".codex/log/codex_ru_dictation_hook_app.log"
  my logMessage("started")
  try
    set lastLine to do shell script "/usr/bin/tail -n 1 " & quoted form of historyPath
  on error
    set lastLine to ""
  end try
  repeat
    my pollOnce()
    delay 0.05
  end repeat
end run

on pollOnce()
  set currentLine to ""
  try
    set currentLine to do shell script "/usr/bin/tail -n 1 " & quoted form of historyPath
  on error
    return
  end try

  if currentLine is "" then return
  if currentLine is not lastLine then
    set lastLine to currentLine
  end if

  set parsed to my parseHistoryLine(lastLine)
  if parsed is missing value then return

  set itemId to item 1 of parsed
  set itemText to item 2 of parsed
  if itemId is "" or itemText is "" or itemId is lastPastedId then return
  if not my isRussianInputSource() then
    my logMessage("skip non-russian input source for id " & itemId)
    return
  end if

  set clipText to ""
  try
    set clipText to the clipboard as text
  on error
    my logMessage("skip clipboard read error for id " & itemId)
    return
  end try

  if clipText is itemText or clipText is (itemText & " ") then
    set lastPastedId to itemId
    try
      tell application "System Events" to key code 9 using command down
      my logMessage("pasted id " & itemId & ": " & itemText)
    on error errMsg number errNo
      my logMessage("paste failed id " & itemId & ": " & errNo & " " & errMsg)
    end try
  else
    my logMessage("skip clipboard mismatch for id " & itemId)
  end if
end pollOnce

on parseHistoryLine(lineText)
  set py to "import json, os" & linefeed & ¬
    "line = os.environ.get('CODEX_DICTATION_JSON', '')" & linefeed & ¬
    "try:" & linefeed & ¬
    "    item = json.loads(line)" & linefeed & ¬
    "    print(str(item.get('id','')) + '\t' + str(item.get('text','')))" & linefeed & ¬
    "except Exception:" & linefeed & ¬
    "    pass"
  try
    set outputText to do shell script "CODEX_DICTATION_JSON=" & quoted form of lineText & " /usr/bin/python3 -c " & quoted form of py
  on error
    return missing value
  end try
  if outputText does not contain tab then return missing value
  set oldDelims to AppleScript's text item delimiters
  set AppleScript's text item delimiters to tab
  set parts to text items of outputText
  set AppleScript's text item delimiters to oldDelims
  if (count of parts) is less than 2 then return missing value
  return {item 1 of parts, item 2 of parts}
end parseHistoryLine

on isRussianInputSource()
  try
    do shell script "/usr/bin/defaults read \"$HOME/Library/Preferences/com.apple.HIToolbox.plist\" AppleSelectedInputSources 2>/dev/null | /usr/bin/grep -Eq 'KeyboardLayout Name\"? = Russian|InputSourceID\"? = .*Russian|Russian'"
    return true
  on error
    return false
  end try
end isRussianInputSource

on logMessage(messageText)
  try
    do shell script "/bin/mkdir -p " & quoted form of ((POSIX path of (path to home folder)) & ".codex/log") & "; /bin/echo " & quoted form of (((current date) as text) & " " & messageText) & " >> " & quoted form of logPath
  end try
end logMessage
