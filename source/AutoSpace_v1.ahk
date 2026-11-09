#Requires AutoHotkey v2.0
#SingleInstance Force
if !A_IsAdmin
{
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}
#Include Notify.ahk

; ---------- State ----------
autoSpace := false

; ---------- Config defaults ----------
cfgPath := A_ScriptDir "\autospace.ini"
keySpace := "Space"
keyPressGap := 200
adjustment := 10
tapMs := 60
hkToggle := "F9"
hkGapDecrease := "-"
hkGapIncrease := "="
boundToggle := ""
boundGapDecrease := ""
boundGapIncrease := ""
minKeyPressGap := 10

ReadCfg(section, key, default) {
    global cfgPath
    return Trim(IniRead(cfgPath, section, key, default))
}

LoadConfig() {
    global keySpace, keyPressGap, adjustment, tapMs
    global hkToggle, hkGapDecrease, hkGapIncrease
    global minKeyPressGap

    keySpace := ReadCfg("Keys", "Key", "Space")
    keyPressGap := ReadCfg("Timing", "KeyPressGap", "200") + 0
    adjustment := ReadCfg("Timing", "Adjustment", "10") + 0
    tapMs := ReadCfg("Timing", "TapMs", "60") + 0

    hkToggle := ReadCfg("Hotkeys", "Toggle", "F9")
    hkGapDecrease := ReadCfg("Hotkeys", "GapDecrease", "-")
    hkGapIncrease := ReadCfg("Hotkeys", "GapIncrease", "=")

    if (keySpace = "")
        keySpace := "Space"
    if (keyPressGap < minKeyPressGap)
        keyPressGap := 200
    if (adjustment < 1)
        adjustment := 10
    if (tapMs < 1)
        tapMs := 60
}

SyncHotkey(&boundHotkey, newHotkey, handler, settingName) {
    oldHotkey := boundHotkey

    try {
        if (oldHotkey != "" && oldHotkey != newHotkey)
            Hotkey(oldHotkey, handler, "Off")
        Hotkey(newHotkey, handler, "On")
        boundHotkey := newHotkey
        return true
    } catch as e {
        if (oldHotkey != "" && oldHotkey != newHotkey) {
            try Hotkey(oldHotkey, handler, "On")
        }
        MsgBox "Invalid " settingName " hotkey in ini: " newHotkey "`n`n" e.Message
        return false
    }
}

SyncToggleHotkey() {
    global hkToggle, boundToggle
    return SyncHotkey(&boundToggle, hkToggle, ToggleAutoSpace, "Toggle")
}

EnableGapHotkeys() {
    global hkGapDecrease, hkGapIncrease, boundGapDecrease, boundGapIncrease

    if (!SyncHotkey(&boundGapDecrease, hkGapDecrease, GapDecrease, "GapDecrease"))
    {
        DisableGapHotkeys()
        return false
    }
    if (!SyncHotkey(&boundGapIncrease, hkGapIncrease, GapIncrease, "GapIncrease"))
    {
        DisableGapHotkeys()
        return false
    }
    return true
}

DisableGapHotkeys() {
    global boundGapDecrease, boundGapIncrease

    if (boundGapDecrease != "")
    {
        try Hotkey(boundGapDecrease, GapDecrease, "Off")
    }
    if (boundGapIncrease != "")
    {
        try Hotkey(boundGapIncrease, GapIncrease, "Off")
    }
}

ReloadConfig() {
    LoadConfig()
    if (!SyncToggleHotkey())
        return false
    return EnableGapHotkeys()
}

; ---------- Helpers ----------
SendKeyDown(key) => SendEvent("{" key " down}")
SendKeyUp(key)   => SendEvent("{" key " up}")

TapKey(key, holdMs) {
    SendKeyDown(key)
    Sleep holdMs
    SendKeyUp(key)
}

SleepWhileRunning(totalMs) {
    global autoSpace

    start := A_TickCount
    while (autoSpace && (A_TickCount - start) < totalMs) {
        remaining := totalMs - (A_TickCount - start)
        Sleep (remaining < 20 ? remaining : 20)
    }
    return autoSpace
}

ShowNotify(tag, title, message, color := "0x0BFF0B", sound := "Windows Ding") {
    if (hwnd := Notify.Exist(tag))
        WinClose("ahk_id " hwnd)

    Notify.Show(title, message, , sound, ,
        "tag=" tag " theme=Aurora dur=3 ts=16 tc=0x80FF80 tf=Microsoft YaHei"
        . " ms=16 mc=" color " mf=Microsoft YaHei")
}

; ---------- Config writeback ----------
SafeWriteGap() {
    global keyPressGap, cfgPath

    try
    {
        content := FileRead(cfgPath, "UTF-8")
    }
    catch
    {
        if (FileExist(cfgPath))
            return false
        content := ""
    }

    newline := ((content = "") || InStr(content, "`r`n")) ? "`r`n" : "`n"

    if (content = "")
        lines := []
    else
        lines := StrSplit(content, "`n", "`r")

    output := []
    inTiming := false
    sectionFound := false
    keyWritten := false

    for line in lines
    {
        trimmed := Trim(line)

        if (RegExMatch(trimmed, "^\[([^\]]+)\]", &sectionMatch))
        {
            if (inTiming && !keyWritten)
            {
                output.Push("KeyPressGap=" keyPressGap)
                keyWritten := true
            }

            inTiming := (sectionMatch[1] = "Timing")
            if (inTiming)
                sectionFound := true
        }
        else if (inTiming && !keyWritten && RegExMatch(trimmed, "i)^KeyPressGap[ \t]*="))
        {
            line := "KeyPressGap=" keyPressGap
            keyWritten := true
        }

        output.Push(line)
    }

    if (!keyWritten)
    {
        if (!sectionFound)
        {
            if (output.Length > 0 && output[output.Length] != "")
                output.Push("")
            output.Push("[Timing]")
        }
        output.Push("KeyPressGap=" keyPressGap)
    }

    newContent := ""
    for index, line in output
    {
        if (index > 1)
            newContent .= newline
        newContent .= line
    }

    try
    {
        file := FileOpen(cfgPath, "w", "UTF-8-RAW")
        if (!file)
            return false
        file.Write(newContent)
        file.Close()
        return true
    }
    catch
    {
        return false
    }
}

; ---------- Toggle / adjustment handlers ----------
ToggleAutoSpace(*) {
    global autoSpace, keyPressGap

    if (!autoSpace) {
        if (!ReloadConfig())
            return

        autoSpace := true
        ShowNotify("AutoSpaceToggle", "自动连按空格 ⌨️", "开始 🟢`n`n按键间隔 " keyPressGap " 毫秒")
    } else {
        autoSpace := false
        DisableGapHotkeys()

        saved := SafeWriteGap()
        message := "停止 🔴`n`n按键间隔 " keyPressGap " 毫秒"
        if (saved)
            message .= "`n已写入配置"
        else
            message .= "`n写入配置失败"

        ShowNotify("AutoSpaceToggle", "自动连按空格 ⌨️", message, "Red", "Windows Restore")
    }
}

AdjustGap(direction) {
    global autoSpace, keyPressGap, adjustment, minKeyPressGap

    if (!autoSpace)
        return

    newGap := keyPressGap + direction * adjustment
    if (newGap < minKeyPressGap)
        newGap := minKeyPressGap
    keyPressGap := newGap

    ShowNotify("AutoSpaceGap", "自动连按空格 ⌨️", "按键间隔 " keyPressGap " 毫秒")
}

GapDecrease(*) {
    AdjustGap(-1)
}

GapIncrease(*) {
    AdjustGap(1)
}

; ---------- Register configurable hotkeys ----------
LoadConfig()
if (!SyncToggleHotkey())
    ExitApp

; ---------- Main loop ----------
Loop {
    if (!autoSpace) {
        Sleep 50
        continue
    }

    TapKey(keySpace, tapMs)

    if (!SleepWhileRunning(keyPressGap))
        continue
}
