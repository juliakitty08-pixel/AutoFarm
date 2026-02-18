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

; Heal cooldown (ONLY configurable timing)
global healCooldownMs := ReadCfg("Timing","HealCooldownMs","60000") + 0

global nextHealTick := 0


; Gather config (loaded from ini)
global gatherKey := ReadCfg("Gather","Key","f")
global gatherIntervalMs := ReadCfg("Gather","IntervalMs","10000") + 0
if (gatherIntervalMs < 1000)
    gatherIntervalMs := 10000

; ---------- Helpers ----------
SendKeyDown(key) => SendEvent("{" key " down}")
SendKeyUp(key)   => SendEvent("{" key " up}")

TapKey(key, tapMs := 60) {
    SendKeyDown(key)
    Sleep tapMs
    SendKeyUp(key)
}

HoldKey(key, holdMs) {
    SendKeyDown(key)
    Sleep holdMs
    SendKeyUp(key)
}

CastHeal() {
    global keyHeal, healPostDelayMs

    ; For backtick/tilde (and many special keys), use a simple tap form.   
    SendEvent("{" keyHeal "}")
}

GatherTick() {
    global autogather, gatherKey, msTap
    if (!autogather)
        return
    TapKey(gatherKey, msTap)
}

; ---------- Toggle ----------

F10:: {
    global autogather, gatherIntervalMs

    autogather := !autogather

    tag := "AutoGatherToggle"
    if (hwnd := Notify.Exist(tag))
        WinClose("ahk_id " hwnd)

    if (autogather) {
        Notify.Show("自动采集 🧺","开始 🟢`n`n记得你雪姐的好!",,"Windows Ding",,
            "tag=" tag " theme=Aurora dur=3 ts=16 tc=0x80FF80 tf=Microsoft YaHei"
            . " ms=16 mc=0x0BFF0B mf=Microsoft YaHei")

        GatherTick()                         ; fire once now
        SetTimer(GatherTick, gatherIntervalMs) ; then repeat
    } else {
        Notify.Show("自动采集 🧺","停止 🔴",,"Windows Restore",,
            "tag=" tag " theme=Aurora dur=3 ts=16 tc=0x80FF80 tf=Microsoft YaHei"
            . " ms=16 mc=Red mf=Microsoft YaHei")

        SetTimer(GatherTick, 0)              ; stop
    }
}



F11:: {
    global autofarm, loopCount, nextHealTick, healCooldownMs, healPostDelayMs

    autofarm := !autofarm
    loopCount := 0
    nextHealTick := 0

    tag := "AutoFarmToggle"
    if (hwnd := Notify.Exist(tag))
        WinClose("ahk_id " hwnd)

    if (autofarm) {

        Notify.Show("自动刷宝 🌾","开始 🟢`n`n记得你雪姐的好!",,"Windows Ding",,
            "tag=" tag " theme=Aurora dur=3 ts=16 tc=0x80FF80 tf=Microsoft YaHei"
            . " ms=16 mc=0x0BFF0B mf=Microsoft YaHei")

        ; Immediate heal on start
        CastHeal()
        Sleep healPostDelayMs

        nextHealTick := A_TickCount + healCooldownMs
    }
    else {

        Notify.Show("自动刷宝 🌾","停止 🔴",,"Windows Restore",,
            "tag=" tag " theme=Aurora dur=3 ts=16 tc=0x80FF80 tf=Microsoft YaHei"
            . " ms=16 mc=Red mf=Microsoft YaHei")
    }
}

; ---------- Autofarm loop ----------
$F1::return

Loop {

    global autofarm, loopCount
    global keyMeteorFlight, keyMightyDrop, keyDragonsBreath
    global msBetween1, msBetween2, msMeteorHold, msTap
    global msAfterMeteorTap, msAfterMightyDrop
    global msBeforeDragonsBreath, msAfterDragonsBreath
    global nextHealTick, healCooldownMs
    global healPreDelayMs, healPostDelayMs

    if (!autofarm) {
        Sleep 50
        continue
    }

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

    Sleep msBeforeDragonsBreath

    ; Dragon's Breath (神龙吐火)
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
