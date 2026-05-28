#Requires AutoHotkey v2.0

#SingleInstance Force
SendMode "Event"  ; Event mode is often more reliable in games than Input mode.

autoAttackEnabled := false
isSpamming := false
spamIntervalMs := 10
rHotkeyPaused := false
pauseToggleCooldownMs := 300
lastPauseToggleTick := 0
statusGui := unset
statusText := unset

#HotIf !rHotkeyPaused
R::
{
	global autoAttackEnabled, isSpamming

	autoAttackEnabled := !autoAttackEnabled

	if !autoAttackEnabled {
		isSpamming := false
	}

	ShowToggleStatus(autoAttackEnabled)
}
#HotIf

F3::
{
	ToggleRHotkeyPause()
}

#HotIf autoAttackEnabled
*LButton::
{
	global autoAttackEnabled, isSpamming, spamIntervalMs

	if isSpamming
		return

	isSpamming := true

	while autoAttackEnabled && GetKeyState("LButton", "P") {
		Click "Left"

		remaining := spamIntervalMs
		while remaining > 0 && autoAttackEnabled && GetKeyState("LButton", "P") {
			sleepChunk := Min(remaining, 5)
			Sleep sleepChunk
			remaining -= sleepChunk
		}
	}

	isSpamming := false
}

*LButton Up::
{
	global isSpamming

	isSpamming := false
}
#HotIf

ShowToggleStatus(enabled)
{
	global statusGui, statusText

	if !IsSet(statusGui) {
		statusGui := Gui("-Caption +AlwaysOnTop +ToolWindow +Border")
		statusGui.BackColor := "111111"
		statusGui.SetFont("s11 cFFFFFF", "Segoe UI")
		statusText := statusGui.AddText("Center w360", "")
	}

	message := enabled ? "Autoattack turned on." : "Autoattack turned off."
	statusText.Value := message

	statusGui.Show("AutoSize Hide")
	statusGui.GetPos(, , &guiW, &guiH)
	x := (A_ScreenWidth - guiW) // 2
	y := Round(A_ScreenHeight * 0.10)
	statusGui.Show(Format("NoActivate x{} y{}", x, y))

	SetTimer(HideToggleStatus, -1200)
}

HideToggleStatus()
{
	global statusGui

	if IsSet(statusGui)
		statusGui.Hide()
}

ToggleRHotkeyPause()
{
	global rHotkeyPaused, pauseToggleCooldownMs, lastPauseToggleTick

	if A_TickCount - lastPauseToggleTick < pauseToggleCooldownMs
		return

	lastPauseToggleTick := A_TickCount

	rHotkeyPaused := !rHotkeyPaused
	message := rHotkeyPaused ? "R toggle paused (typing mode)." : "R toggle resumed."
	ShowStatusMessage(message)
}

ShowStatusMessage(message)
{
	global statusGui, statusText

	if !IsSet(statusGui) {
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

	SetTimer(HideToggleStatus, -1200)
}
