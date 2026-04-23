#Requires AutoHotkey v2.0
#SingleInstance Force
if !A_IsAdmin
{
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}
#Include Notify.ahk

autofarm := false
autogather := false
autobeef := false
autojade := false

; ---------- Config loading ----------
cfgPath := A_ScriptDir "\autofarm.ini"
keyMeteorFlight := "Space"
keyMightyDrop := "q"
keyDragonsBreath := "x"
keyHeal := "sc029"
keyDeath := "f"
keyLoot := "f"
keyMoSpecial := "sc029"
keyJadeDodge := "LShift"
msTap := 60
msInitial := 100
msMeteorHold := 2000
msBeforeMightyDrop := 3500
msBeforeDragonsBreath := 1200
msAfterDragonsBreath := 2000
numberTouchOfDeath := 10
msBeforeTouchOfDeath := 300
msBetweenTouchOfDeath := 100
msAfterTouchOfDeath := 1800
msAfterLoot := 500
healPreDelayMs := 1100
healPostDelayMs := 1000
msJadeStart := 100
msAfterMoSpecial := 4000
msJadeInterval := 300000
healCooldownMs := 60000
gatherKey := "f"
gatherIntervalMs := 10000
hkToggleGather := "F10"
hkToggleFarm := "F9"
hkToggleBeef := "F8"
hkToggleJade := "F7"
boundToggleGather := ""
boundToggleFarm := ""
boundToggleBeef := ""
boundToggleJade := ""
nextHealTick := 0

ReadCfg(section, key, default) {
    global cfgPath
    return Trim(IniRead(cfgPath, section, key, default))
}

LoadConfig() {
    global keyMeteorFlight, keyMightyDrop, keyDragonsBreath, keyHeal
    global keyDeath, keyLoot, keyMoSpecial, keyJadeDodge
    global msTap, msInitial, msMeteorHold, msBeforeMightyDrop
    global msBeforeDragonsBreath, msAfterDragonsBreath
    global numberTouchOfDeath, msBeforeTouchOfDeath, msBetweenTouchOfDeath
    global msAfterTouchOfDeath, msAfterLoot
    global healPreDelayMs, healPostDelayMs, msJadeStart, msAfterMoSpecial
    global msJadeInterval, healCooldownMs
    global gatherKey, gatherIntervalMs
    global hkToggleGather, hkToggleFarm, hkToggleBeef, hkToggleJade

    keyMeteorFlight := ReadCfg("Keys", "MeteorFlight", "Space")
    keyMightyDrop := ReadCfg("Keys", "MightyDrop", "q")
    keyDragonsBreath := ReadCfg("Keys", "DragonsBreath", "x")
    keyHeal := ReadCfg("Keys", "Heal", "sc029")
    keyDeath := ReadCfg("Keys", "TouchOfDeath", "f")
    keyLoot := ReadCfg("Keys", "Loot", "f")
    keyMoSpecial := ReadCfg("Keys", "MoSpecial", "sc029")
    keyJadeDodge := ReadCfg("Keys", "Dodge", "LShift")

    msTap := ReadCfg("Timing", "TapMs", "60") + 0
    msInitial := ReadCfg("Timing", "InitialDelayMs", "100") + 0
    msMeteorHold := ReadCfg("Timing", "MeteorHoldMs", "2000") + 0
    msBeforeMightyDrop := ReadCfg("Timing", "BeforeMightyDropMs", "3500") + 0
    msBeforeDragonsBreath := ReadCfg("Timing", "BeforeDragonsBreathMs", "1200") + 0
    msAfterDragonsBreath := ReadCfg("Timing", "AfterDragonsBreathMs", "2000") + 0
    numberTouchOfDeath := ReadCfg("Timing", "TouchOfDeathCount", "10") + 0
    msBeforeTouchOfDeath := ReadCfg("Timing", "BeforeTouchOfDeathMs", "300") + 0
    msBetweenTouchOfDeath := ReadCfg("Timing", "BetweenTouchOfDeathMs", "100") + 0
    msAfterTouchOfDeath := ReadCfg("Timing", "AfterTouchOfDeathMs", "1800") + 0
    msAfterLoot := ReadCfg("Timing", "AfterLootMs", "500") + 0
    healPreDelayMs := ReadCfg("Timing", "HealPreDelayMs", "1100") + 0
    healPostDelayMs := ReadCfg("Timing", "HealPostDelayMs", "1000") + 0
    msJadeStart := ReadCfg("Timing", "JadeStartDelayMs", "100") + 0
    msAfterMoSpecial := ReadCfg("Timing", "AfterMoSpecialMs", "4000") + 0
    msJadeInterval := ReadCfg("Timing", "JadeIntervalMs", "300000") + 0
    healCooldownMs := ReadCfg("Timing", "HealCooldownMs", "60000") + 0

    gatherKey := ReadCfg("Gather", "Key", "f")
    gatherIntervalMs := ReadCfg("Gather", "IntervalMs", "10000") + 0
    if (gatherIntervalMs < 1000)
        gatherIntervalMs := 10000

    hkToggleGather := ReadCfg("Hotkeys", "ToggleGather", "F10")
    hkToggleFarm := ReadCfg("Hotkeys", "ToggleFarm", "F9")
    hkToggleBeef := ReadCfg("Hotkeys", "ToggleBeef", "F8")
    hkToggleJade := ReadCfg("Hotkeys", "ToggleJade", "F7")
}

SyncOneHotkey(&boundHotkey, newHotkey, handler, settingName) {
    oldHotkey := boundHotkey
    if (newHotkey = oldHotkey && oldHotkey != "")
        return true

    try {
        if (oldHotkey != "")
            Hotkey(oldHotkey, handler, "Off")
        Hotkey(newHotkey, handler, "On")
        boundHotkey := newHotkey
        return true
    } catch as e {
        if (oldHotkey != "" && newHotkey != oldHotkey) {
            try Hotkey(oldHotkey, handler, "On")
        }
        MsgBox "Invalid " settingName " hotkey in ini: " newHotkey "`n`n" e.Message
        return false
    }
}

SyncToggleHotkeys() {
    global hkToggleGather, hkToggleFarm, hkToggleBeef, hkToggleJade
    global boundToggleGather, boundToggleFarm, boundToggleBeef, boundToggleJade

    ok := true
    ok := SyncOneHotkey(&boundToggleGather, hkToggleGather, ToggleGather, "ToggleGather") && ok
    ok := SyncOneHotkey(&boundToggleFarm, hkToggleFarm, ToggleFarm, "ToggleFarm") && ok
    ok := SyncOneHotkey(&boundToggleBeef, hkToggleBeef, ToggleBeef, "ToggleBeef") && ok
    ok := SyncOneHotkey(&boundToggleJade, hkToggleJade, ToggleJade, "ToggleJade") && ok
    return ok
}

ReloadConfig() {
    LoadConfig()
    return SyncToggleHotkeys()
}

LoadConfig()

; ---------- Helpers ----------
SendKeyDown(key) => SendEvent("{" key " down}")
SendKeyUp(key)   => SendEvent("{" key " up}")

TapKey(key, tapMs := 60) {
    SendKeyDown(key)
    Sleep tapMs
    SendKeyUp(key)
}

RepeatTap(key, count, tapMs := 60, gapMs := 200) {
    Loop count {
        TapKey(key, tapMs)
        if (A_Index < count)
            Sleep gapMs
    }
}

HoldKey(key, holdMs) {
    SendKeyDown(key)
    Sleep holdMs
    SendKeyUp(key)
}

CastHeal() {
    global keyHeal
    SendEvent("{" keyHeal "}")
}

GatherTick() {
    global autogather, gatherKey, msTap
    if (!autogather)
        return
    TapKey(gatherKey, msTap)
}

StopGatherIfNeeded() {
    global autogather
    if (autogather) {
        autogather := false
        SetTimer(GatherTick, 0)
        ShowNotify("AutoGatherToggle", "自动采集 🧺", "停止 🔴", "Red", "Windows Restore")
    }
}

ShowNotify(tag, title, message, color := "0x0BFF0B", sound := "Windows Ding") {
    if (hwnd := Notify.Exist(tag))
        WinClose("ahk_id " hwnd)

    Notify.Show(title, message, , sound, ,
        "tag=" tag " theme=Aurora dur=3 ts=16 tc=0x80FF80 tf=Microsoft YaHei"
        . " ms=16 mc=" color " mf=Microsoft YaHei")
}

InterruptibleSleepAccurate(totalMs, mode := "") {
    global autojade

    start := A_TickCount
    step := 100

    while ((A_TickCount - start) < totalMs) {
        if (mode = "jade" && !autojade)
            return false

        remaining := totalMs - (A_TickCount - start)
        chunk := (remaining < step ? remaining : step)
        Sleep chunk
    }
    return true
}

; ---------- Toggle handlers ----------
ToggleGather(*) {
    global autogather, autofarm, autobeef, autojade, gatherIntervalMs

    nextState := !autogather
    if (nextState && !ReloadConfig())
        return
    autogather := nextState

    if (autogather) {
        if (autobeef) {
            autobeef := false
            ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
        }
        if (autofarm) {
            autofarm := false
            ShowNotify("AutoFarmToggle", "自动刷宝 🌾", "停止 🔴", "Red", "Windows Restore")
        }
        if (autojade) {
            autojade := false
            ShowNotify("AutoJadeToggle", "自动刷玉 🟢", "停止 🔴", "Red", "Windows Restore")
        }

        ShowNotify("AutoGatherToggle", "自动采集 🧺", "开始 🟢`n`n记得你雪姐的好!")
        GatherTick()
        SetTimer(GatherTick, gatherIntervalMs)
    } else {
        ShowNotify("AutoGatherToggle", "自动采集 🧺", "停止 🔴", "Red", "Windows Restore")
        SetTimer(GatherTick, 0)
    }
}

ToggleFarm(*) {
    global autofarm, autobeef, autojade
    global nextHealTick, healCooldownMs, healPostDelayMs

    nextState := !autofarm
    if (nextState && !ReloadConfig())
        return
    autofarm := nextState

    if (autofarm) {
        if (autobeef) {
            autobeef := false
            ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
        }
        if (autojade) {
            autojade := false
            ShowNotify("AutoJadeToggle", "自动刷玉 🟢", "停止 🔴", "Red", "Windows Restore")
        }

        StopGatherIfNeeded()

        nextHealTick := 0

        ShowNotify("AutoFarmToggle", "自动刷宝 🌾", "开始 🟢`n`n记得你雪姐的好!")

        CastHeal()
        Sleep healPostDelayMs
        nextHealTick := A_TickCount + healCooldownMs
    } else {
        nextHealTick := 0
        ShowNotify("AutoFarmToggle", "自动刷宝 🌾", "停止 🔴", "Red", "Windows Restore")
    }
}

ToggleBeef(*) {
    global autobeef, autofarm, autojade
    global nextHealTick

    nextState := !autobeef
    if (nextState && !ReloadConfig())
        return
    autobeef := nextState

    if (autobeef) {
        if (autofarm) {
            autofarm := false
            ShowNotify("AutoFarmToggle", "自动刷宝 🌾", "停止 🔴", "Red", "Windows Restore")
        }
        if (autojade) {
            autojade := false
            ShowNotify("AutoJadeToggle", "自动刷玉 🟢", "停止 🔴", "Red", "Windows Restore")
        }

        StopGatherIfNeeded()

        nextHealTick := 0
        ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "开始 🟢`n`n记得你雪姐的好!")
    } else {
        ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
    }
}

ToggleJade(*) {
    global autojade, autofarm, autobeef
    global nextHealTick

    nextState := !autojade
    if (nextState && !ReloadConfig())
        return
    autojade := nextState

    if (autojade) {
        if (autofarm) {
            autofarm := false
            ShowNotify("AutoFarmToggle", "自动刷宝 🌾", "停止 🔴", "Red", "Windows Restore")
        }
        if (autobeef) {
            autobeef := false
            ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
        }

        StopGatherIfNeeded()

        nextHealTick := 0
        ShowNotify("AutoJadeToggle", "自动刷玉 🟢", "开始 🟢`n`n记得你雪姐的好!")
    } else {
        ShowNotify("AutoJadeToggle", "自动刷玉 🟢", "停止 🔴", "Red", "Windows Restore")
    }
}

; ---------- Register configurable hotkeys ----------
if (!SyncToggleHotkeys())
    ExitApp

; Keep your original "disable F1" line
$F1::return

; ---------- Main loop ----------
Loop {
    if (!autofarm && !autobeef && !autojade) {
        Sleep 50
        continue
    }

    ; Snapshot mode at the start so the current loop always finishes.
    if (autofarm)
        currentMode := "farm"
    else if (autobeef)
        currentMode := "beef"
    else
        currentMode := "jade"

    if (currentMode = "farm") {
        Sleep msInitial

        ; Meteor Flight (飒踏流星)
        HoldKey(keyMeteorFlight, msMeteorHold)

        TapKey(keyMeteorFlight, msTap)

        Sleep msBeforeMightyDrop

        ; Mighty Drop (千斤坠)
        TapKey(keyMightyDrop, msTap)

        ; Dragon's Breath (神龙吐火)
        Sleep msBeforeDragonsBreath
        TapKey(keyDragonsBreath, msTap)
        Sleep msAfterDragonsBreath

        ; Heal when cooldown ready
        if (nextHealTick != 0 && A_TickCount >= nextHealTick) {
            Sleep healPreDelayMs
            CastHeal()
            Sleep healPostDelayMs
            nextHealTick := A_TickCount + healCooldownMs
        }
    }
    else if (currentMode = "beef") {
        Sleep msInitial

        ; Meteor Flight (飒踏流星)
        HoldKey(keyMeteorFlight, msMeteorHold)

        TapKey(keyMeteorFlight, msTap)

        Sleep msBeforeMightyDrop

        ; Mighty Drop (千斤坠)
        TapKey(keyMightyDrop, msTap)

        ; Touch of Death (灵虚一指)
        Sleep msBeforeTouchOfDeath
        RepeatTap(keyDeath, numberTouchOfDeath, msTap, msBetweenTouchOfDeath)
        Sleep msAfterTouchOfDeath

        TapKey(keyLoot, msTap)
        Sleep msAfterLoot
    }
    else if (currentMode = "jade") {
        if (!InterruptibleSleepAccurate(msJadeStart, "jade"))
            continue

        if (!autojade)
            continue
        TapKey(keyMoSpecial, msTap)

        if (!InterruptibleSleepAccurate(msAfterMoSpecial, "jade"))
            continue

        ; stop immediately before movement sequence if toggled off
        if (!autojade)
            continue
        TapKey(keyJadeDodge, msTap)

        ; this is the important one: do not get stuck for 5 minutes
        if (!InterruptibleSleepAccurate(msJadeInterval, "jade"))
            continue
    }
}
