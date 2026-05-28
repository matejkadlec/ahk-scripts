#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
#UseHook

; Minecraft Active-Window Right-Button Holder
;
; Configuration:
HOLD_CHECK_INTERVAL_MS := 50
HOLD_BUTTON := "RButton"
TARGET_PROCESS := "javaw.exe"
TARGET_WINDOW_TITLE := ""  ; Optional partial title, for example: "Minecraft"
MISSING_WINDOW_NOTICE_MS := 5000

; Hotkeys:
; - F6 toggles holding right mouse button.
; - F8 exits the script.
;
; Notes:
; - This holds RMB down instead of spamming separate right-clicks.
; - The button is held only while Minecraft is the active window.
; - The button is released when disabled, Minecraft loses focus, or the script exits.
; - Keep Minecraft focused when you want the holder to run.
; - If Minecraft is running as admin, run this script as admin too.

SetTitleMatchMode(2)
SendMode("Event")

holderEnabled := false
buttonHeld := false
lastMissingWindowNoticeTick := 0

OnExit(ExitHandler)

$*F6::
{
    KeyWait("F6")
    ToggleHolder()
}

$*F8::ExitApp()

ToggleHolder() {
    global holderEnabled, HOLD_CHECK_INTERVAL_MS

    holderEnabled := !holderEnabled

    if holderEnabled {
        SetTimer(MaintainHold, HOLD_CHECK_INTERVAL_MS)
        MaintainHold()
    } else {
        SetTimer(MaintainHold, 0)
        ReleaseHold()
    }

    Notify(holderEnabled ? "Enabled - holding right mouse button" : "Disabled - released right mouse button")
}

MaintainHold() {
    global holderEnabled

    if !holderEnabled {
        ReleaseHold()
        return
    }

    targetWin := FindTargetWindow()
    if (targetWin = "") {
        ReleaseHold()
        NotifyMissingWindow()
        return
    }

    if !WinActive(targetWin) {
        ReleaseHold()
        return
    }

    PressHold()
}

PressHold() {
    global buttonHeld, HOLD_BUTTON

    if buttonHeld
        return

    SendEvent("{" HOLD_BUTTON " down}")
    buttonHeld := true
}

ReleaseHold() {
    global buttonHeld, HOLD_BUTTON

    if !buttonHeld
        return

    SendEvent("{" HOLD_BUTTON " up}")
    buttonHeld := false
}

FindTargetWindow() {
    targetQuery := BuildTargetQuery()
    hwnd := WinExist(targetQuery)
    return hwnd ? "ahk_id " hwnd : ""
}

BuildTargetQuery() {
    global TARGET_PROCESS, TARGET_WINDOW_TITLE

    titlePart := TARGET_WINDOW_TITLE != "" ? TARGET_WINDOW_TITLE " " : ""
    return titlePart "ahk_exe " TARGET_PROCESS
}

NotifyMissingWindow() {
    global lastMissingWindowNoticeTick, MISSING_WINDOW_NOTICE_MS

    if (A_TickCount - lastMissingWindowNoticeTick < MISSING_WINDOW_NOTICE_MS)
        return

    lastMissingWindowNoticeTick := A_TickCount
    Notify("Minecraft window not found.")
}

Notify(message) {
    TrayTip(message, "Minecraft RMB Holder")
}

ExitHandler(reason, code) {
    ReleaseHold()
}
