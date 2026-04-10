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
global loopCount := 0

; ---------- Hard-coded combat timings ----------
global msMeteorHold := 2000
global msTap := 60
global msBetween1 := 100
global msBetween2 := 100
global msAfterMeteorTap := 3000
global msAfterMightyDrop := 500
global msBeforeDragonsBreath := 1200
global msAfterDragonsBreath := 2000
global msBeforeTouchOfDeath := 500
global msBetweenTouchOfDeath := 200
global msAfterTouchOfDeath := 2000
global msAfterLoot := 500

global healPreDelayMs := 1100
global healPostDelayMs := 1000

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

; Heal cooldown (ONLY configurable timing)
global healCooldownMs := ReadCfg("Timing","HealCooldownMs","60000") + 0
global nextHealTick := 0

; Gather config (loaded from ini)
global gatherKey := ReadCfg("Gather","Key","f")
global gatherIntervalMs := ReadCfg("Gather","IntervalMs","10000") + 0
if (gatherIntervalMs < 1000)
    gatherIntervalMs := 10000

; Toggle hotkeys (configurable)
global hkToggleGather := ReadCfg("Hotkeys","ToggleGather","F10")
global hkToggleFarm   := ReadCfg("Hotkeys","ToggleFarm","F9")
global hkToggleBeef   := ReadCfg("Hotkeys","ToggleBeef","F8")

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

ShowNotify(tag, title, message, color := "0x0BFF0B", sound := "Windows Ding") {
    if (hwnd := Notify.Exist(tag))
        WinClose("ahk_id " hwnd)

    Notify.Show(title, message, , sound, ,
        "tag=" tag " theme=Aurora dur=3 ts=16 tc=0x80FF80 tf=Microsoft YaHei"
        . " ms=16 mc=" color " mf=Microsoft YaHei")
}

; ---------- Toggle handlers ----------
ToggleGather(*) {
    global autogather, gatherIntervalMs

    autogather := !autogather

    tag := "AutoGatherToggle"

    if (autogather) {
        if (autobeef) {
            autobeef := false
            ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
        }
        if (autofarm) {
            autofarm := false
            ShowNotify("AutoFarmToggle", "自动刷宝 🌾", "停止 🔴", "Red", "Windows Restore")
        } 
        ShowNotify(tag, "自动采集 🧺", "开始 🟢`n`n记得你雪姐的好!")
        GatherTick()
        SetTimer(GatherTick, gatherIntervalMs)
    } else {
        ShowNotify(tag, "自动采集 🧺", "停止 🔴", "Red", "Windows Restore")
        SetTimer(GatherTick, 0)
    }
}

ToggleFarm(*) {
    global autofarm, autobeef, loopCount, nextHealTick, healCooldownMs, healPostDelayMs

    autofarm := !autofarm

    if (autofarm) {
        if (autobeef) {
            autobeef := false
            ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
        }
        if (autogather) {
            autogather := false
            ShowNotify("AutoGatherToggle", "自动采集 🧺", "停止 🔴", "Red", "Windows Restore")            
        }
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
    global autobeef, autofarm, loopCount, nextHealTick

    autobeef := !autobeef

    if (autobeef) {
        if (autofarm) {
            autofarm := false
            ShowNotify("AutoFarmToggle", "自动刷宝 🌾", "停止 🔴", "Red", "Windows Restore")
        }
        if (autogather) {
            autogather := false
            ShowNotify("AutoGatherToggle", "自动采集 🧺", "停止 🔴", "Red", "Windows Restore")            
        }        
        loopCount := 0
        nextHealTick := 0
        ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "开始 🟢`n`n记得你雪姐的好!")
        
    } else {
        ShowNotify("AutoBeefToggle", "自动刷牛筋 🥩", "停止 🔴", "Red", "Windows Restore")
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

; Keep your original "disable F1" line
$F1::return

; ---------- Autofarm / AutoBeef loop ----------
Loop {
    global autofarm, autobeef, loopCount
    global keyMeteorFlight, keyMightyDrop, keyDragonsBreath, keyDeath
    global msBetween1, msBetween2, msMeteorHold, msTap
    global msAfterMeteorTap, msAfterMightyDrop
    global msBeforeDragonsBreath, msAfterDragonsBreath
    global nextHealTick, healCooldownMs
    global healPreDelayMs, healPostDelayMs

    if (!autofarm && !autobeef) {
        Sleep 50
        continue
    }

    currentMode := autofarm ? "farm" : "beef"
    loopCount += 1

    Sleep msBetween1

    ; Meteor Flight (飒踏流星)
    HoldKey(keyMeteorFlight, msMeteorHold)

    Sleep msBetween2

    TapKey(keyMeteorFlight, msTap)

    Sleep msAfterMeteorTap

    ; Mighty Drop (千斤坠)
    TapKey(keyMightyDrop, msTap)

    Sleep msAfterMightyDrop

    ; Mighty Drop again
    TapKey(keyMightyDrop, msTap)    

    if (currentMode = "farm") {
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
        ; Touch of Death (灵虚一指)
        Sleep msBeforeTouchOfDeath
        RepeatTap(keyDeath, 6, msTap, msBetweenTouchOfDeath)
        Sleep msAfterTouchOfDeath
        TapKey(keyLoot, msTap)
        Sleep msAfterLoot
        ; no heal in beef rotation
    }
}