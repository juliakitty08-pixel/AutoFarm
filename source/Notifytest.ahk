#Requires AutoHotkey v2.0
#SingleInstance Force

; Put Notify.ahk somewhere AHK can find it (same folder as your script, or a Lib folder)
#Include Notify.ahk

global toggle := false

F12:: {
    global toggle
    toggle := !toggle

    title := "Macro Toggle"
    msg   := "Macro is now " (toggle ? "AutoHeal🩹 ON 🟢" : "AutoHeal🩹 OFF 🔴")

    ; Overwrite behavior: close prior notification with same tag (if any)
    if (hwnd := Notify.Exist("AutoHealToggle"))
        WinClose("ahk_id " hwnd)

    ; Show new one
    ; Signature you already found: Show(title, message, image, sound, callback, options)
    Notify.Show(title, msg, , , , "tag=AutoHealToggle theme=Aurora")
}
