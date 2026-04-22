#Requires AutoHotkey v2.0
#SingleInstance Force
if !A_IsAdmin
{
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}
#Include Notify.ahk

global autofarm := false
global autogather := false
global autobeef := false
global autojade := false
global loopCount := 0

; ---------- Hard-coded combat timings ----------
global msTap := 60
global msInitial := 100
global msMeteorHold := 2000
global msBeforeMightyDrop := 3500
global msBeforeDragonsBreath := 1200
global msAfterDragonsBreath := 2000
global numberTouchOfDeath := 10
global msBeforeTouchOfDeath := 300
global msBetweenTouchOfDeath := 100
global msAfterTouchOfDeath := 1800
global msAfterLoot := 500

global healPreDelayMs := 1100
global healPostDelayMs := 1000

; Jade loop timings
global msJadeStart := 100
global msAfterMoSpecial := 4000


; ---------- Config loading ----------
global cfgPath := A_ScriptDir "\autofarm.ini"

ReadCfg(section, key, default) {
    global cfgPath
    return Trim(IniRead(cfgPath, section, key, default))
}

; Ability keys
global keyMeteorFlight  := ReadCfg("Keys","MeteorFlight","Space")
global keyMightyDrop    := ReadCfg("Keys","MightyDrop","q")
global keyDragonsBreath := ReadCfg("Keys","DragonsBreath","x")
global keyHeal          := ReadCfg("Keys","Heal","sc029")
global keyDeath         := ReadCfg("Keys","TouchOfDeath","f")
global keyLoot          := ReadCfg("Keys","Loot","f")
global keyMoSpecial     := ReadCfg("Keys","MoSpecial","sc029")

; 独山玉采集间隔 5 minutes 300秒
global msJadeInterval   := ReadCfg("Keys","JadeInterval","300000")

; Jade movement keys
global keyJadeDodge     := ReadCfg("Keys","Dodge","LShift")

; Heal cooldown
global healCooldownMs := ReadCfg("Timing","HealCooldownMs","60000") + 0
global nextHealTick := 0

; Gather config
global gatherKey := ReadCfg("Gather","Key","f")
global gatherIntervalMs := ReadCfg("Gather","IntervalMs","10000") + 0
if (gatherIntervalMs < 1000)
    gatherIntervalMs := 10000

; Toggle hotkeys
global hkToggleGather := ReadCfg("Hotkeys","ToggleGather","F10")
global hkToggleFarm   := ReadCfg("Hotkeys","ToggleFarm","F9")
global hkToggleBeef   := ReadCfg("Hotkeys","ToggleBeef","F8")
global hkToggleJade   := ReadCfg("Hotkeys","ToggleJade","F7")

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

; InterruptibleSleep(totalMs, mode := "") {
;     global autojade

;     elapsed := 0
;     step := 100

;     while (elapsed < totalMs) {
;         if (mode = "jade" && !autojade)
;             return false

;         remaining := totalMs - elapsed
;         Sleep (remaining < step ? remaining : step)
;         elapsed += (remaining < step ? remaining : step)
;     }
;     return true
; }

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

    autogather := !autogather

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
    global autofarm, autobeef, autogather, autojade
    global loopCount, nextHealTick, healCooldownMs, healPostDelayMs

    autofarm := !autofarm

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

        loopCount := 0
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
    global autobeef, autofarm, autogather, autojade
    global loopCount, nextHealTick

    autobeef := !autobeef

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

        loopCount := 0
        nextHealTick := 0
        ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "开始 🟢`n`n记得你雪姐的好!")
    } else {
        ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
    }
}

ToggleJade(*) {
    global autojade, autofarm, autobeef, autogather
    global loopCount, nextHealTick

    autojade := !autojade

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

        loopCount := 0
        nextHealTick := 0
        ShowNotify("AutoJadeToggle", "自动刷玉 🟢", "开始 🟢`n`n记得你雪姐的好!")
    } else {
        ShowNotify("AutoJadeToggle", "自动刷玉 🟢", "停止 🔴", "Red", "Windows Restore")
    }
}

; ---------- Register configurable hotkeys ----------
try Hotkey(hkToggleGather, ToggleGather, "On")
catch as e {
    MsgBox "Invalid ToggleGather hotkey in ini: " hkToggleGather "`n`n" e.Message
    ExitApp
}

try Hotkey(hkToggleFarm, ToggleFarm, "On")
catch as e {
    MsgBox "Invalid ToggleFarm hotkey in ini: " hkToggleFarm "`n`n" e.Message
    ExitApp
}

try Hotkey(hkToggleBeef, ToggleBeef, "On")
catch as e {
    MsgBox "Invalid ToggleBeef hotkey in ini: " hkToggleBeef "`n`n" e.Message
    ExitApp
}

try Hotkey(hkToggleJade, ToggleJade, "On")
catch as e {
    MsgBox "Invalid ToggleJade hotkey in ini: " hkToggleJade "`n`n" e.Message
    ExitApp
}

; Keep your original "disable F1" line
$F1::return

; ---------- Main loop ----------
Loop {
    global autofarm, autobeef, autojade, loopCount
    global keyMeteorFlight, keyMightyDrop, keyDragonsBreath, keyDeath, keyLoot
    global keyMoSpecial, keyJadeDodge
    global msInitial, msMeteorHold, msTap
    global msBeforeMightyDrop
    global msBeforeDragonsBreath, msAfterDragonsBreath
    global numberTouchOfDeath, msBeforeTouchOfDeath, msBetweenTouchOfDeath, msAfterTouchOfDeath, msAfterLoot
    global msJadeStart, msAfterMoSpecial, msJadeInterval
    global nextHealTick, healCooldownMs
    global healPreDelayMs, healPostDelayMs

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

    loopCount += 1

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