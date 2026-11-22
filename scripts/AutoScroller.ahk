#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; Auto Scroller
; Simulates nonstop mouse wheel scrolling, back and forth by default.
;
; Configuration:
SCROLL_INTERVAL_MS := 50          ; Delay between wheel notches in ms (lower = faster).
SCROLL_STEPS_PER_DIRECTION := 10  ; Wheel notches before switching direction ("Both" mode only).
SCROLL_MODE := "Both"             ; "Both" = down and back up, "Down" / "Up" = one direction only.
START_DIRECTION := "Down"         ; First direction in "Both" mode: "Down" or "Up".
TOGGLE_HOTKEY := "NumpadAdd"      ; Toggles scrolling while the script is ON.
SCRIPT_HOTKEY := "F12"            ; Turns the script ON / OFF.
START_SCRIPT_ON := true           ; Whether the script starts ON.
STATUS_DURATION_MS := 1200        ; How long the on/off overlay stays visible.

; Hotkeys:
; - Numpad+ toggles scrolling on/off (only while the script is ON).
; - F12 turns the script ON / OFF.
;   - ON: Numpad+ toggles scrolling.
;   - OFF: scrolling stops and Numpad+ types "+" normally until F12 is pressed again.
;
; Notes:
; - F12 is always taken by this script (for example, it no longer opens browser DevTools).
; - Wheel events go where real scrolling would (usually the window under the cursor).
; - The scroll position is kept between toggles, so the back-and-forth does not drift.
; - Exit the script from its tray icon.
; - If the target app runs as admin, run this script as admin too.

scriptOn := START_SCRIPT_ON
scrollerEnabled := false
currentDirection := START_DIRECTION
stepsInDirection := 0
statusGui := 0
statusText := 0

ValidateConfig()

Hotkey("$" SCRIPT_HOTKEY, OnScriptHotkey)

HotIf((*) => scriptOn)
Hotkey("$" TOGGLE_HOTKEY, OnToggleHotkey)
HotIf()

UpdateTrayTip()

OnScriptHotkey(thisHotkey) {
    ToggleScript()
    WaitForRelease(thisHotkey)
}

OnToggleHotkey(thisHotkey) {
    ToggleScroller()
    WaitForRelease(thisHotkey)
}

WaitForRelease(thisHotkey) {
    ; Keep the hotkey thread busy until the key is physically released,
    ; so key auto-repeat does not toggle again while the key is held.
    KeyWait(RegExReplace(thisHotkey, "^[#!^+<>*~$]+"), "P")
}

ToggleScript() {
    global scriptOn, scrollerEnabled

    scriptOn := !scriptOn

    if !scriptOn && scrollerEnabled
        SetScroller(false)

    UpdateTrayTip()
    ShowStatus(scriptOn ? "Auto Scroller ON - toggle key active" : "Auto Scroller OFF - toggle key disabled")
}

ToggleScroller() {
    global scrollerEnabled

    SetScroller(!scrollerEnabled)
    ShowStatus(scrollerEnabled ? "Auto-scroll: ON" : "Auto-scroll: OFF")
}

SetScroller(enabled) {
    global scrollerEnabled, SCROLL_INTERVAL_MS

    scrollerEnabled := enabled

    if enabled {
        SetTimer(ScrollTick, SCROLL_INTERVAL_MS)
        ScrollTick()
    } else {
        SetTimer(ScrollTick, 0)
    }

    UpdateTrayTip()
}

ScrollTick() {
    global scrollerEnabled, currentDirection, stepsInDirection
    global SCROLL_MODE, SCROLL_STEPS_PER_DIRECTION

    if !scrollerEnabled
        return

    direction := (SCROLL_MODE = "Both") ? currentDirection : SCROLL_MODE
    Send("{Wheel" direction "}")

    if (SCROLL_MODE != "Both")
        return

    stepsInDirection += 1
    if (stepsInDirection >= SCROLL_STEPS_PER_DIRECTION) {
        currentDirection := (currentDirection = "Down") ? "Up" : "Down"
        stepsInDirection := 0
    }
}

UpdateTrayTip() {
    global scriptOn, scrollerEnabled

    scriptState := scriptOn ? "ON" : "OFF"
    scrollState := scrollerEnabled ? "ON" : "OFF"
    A_IconTip := "Auto Scroller - script " scriptState ", scrolling " scrollState
}

ShowStatus(message) {
    global statusGui, statusText, STATUS_DURATION_MS

    if !statusGui {
        statusGui := Gui("-Caption +AlwaysOnTop +ToolWindow +Border")
        statusGui.BackColor := "111111"
        statusGui.SetFont("s11 cFFFFFF", "Segoe UI")
        statusText := statusGui.AddText("Center w360", "")
    }

    statusText.Value := message

    statusGui.Show("AutoSize Hide")
    statusGui.GetPos(, , &guiW, &guiH)
    x := (A_ScreenWidth - guiW) // 2
    y := Round(A_ScreenHeight * 0.10)
    statusGui.Show(Format("NoActivate x{} y{}", x, y))

    SetTimer(HideStatus, -STATUS_DURATION_MS)
}

HideStatus() {
    global statusGui

    if statusGui
        statusGui.Hide()
}

ValidateConfig() {
    global SCROLL_INTERVAL_MS, SCROLL_STEPS_PER_DIRECTION, SCROLL_MODE, START_DIRECTION
    global TOGGLE_HOTKEY, SCRIPT_HOTKEY

    if !IsInteger(SCROLL_INTERVAL_MS) || SCROLL_INTERVAL_MS < 1
        Fail("SCROLL_INTERVAL_MS must be a whole number of at least 1.")

    if !IsInteger(SCROLL_STEPS_PER_DIRECTION) || SCROLL_STEPS_PER_DIRECTION < 1
        Fail("SCROLL_STEPS_PER_DIRECTION must be a whole number of at least 1.")

    if !(SCROLL_MODE = "Both" || SCROLL_MODE = "Down" || SCROLL_MODE = "Up")
        Fail('SCROLL_MODE must be "Both", "Down" or "Up".')

    if !(START_DIRECTION = "Down" || START_DIRECTION = "Up")
        Fail('START_DIRECTION must be "Down" or "Up".')

    if (TOGGLE_HOTKEY = "" || SCRIPT_HOTKEY = "" || TOGGLE_HOTKEY = SCRIPT_HOTKEY)
        Fail("TOGGLE_HOTKEY and SCRIPT_HOTKEY must be set and different.")
}

Fail(message) {
    MsgBox(message, "Auto Scroller", "Iconx")
    ExitApp()
}
