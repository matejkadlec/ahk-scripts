#Requires AutoHotkey v2.0.18
#SingleInstance Force
Persistent
#Include %A_ScriptDir%\Logger.ahk
#Include %A_ScriptDir%\DotEnv.ahk

DotEnv.Load()

class VDEExiter {
    static CONFIG := {
        OpenMenuButton: { x: Round(A_ScreenWidth * (940/1920)), y: 5 },
        ExitButton: { x: Round(A_ScreenWidth * (690/1920)), y: 25 },
        WindowTitle: DotEnv.Get("VDE_WINDOW_TITLE"),
        Delay: 500
    }
    
    ExitSequence(*) {
        ; Check if the Virtual Desktop window is active
        if !WinActive(VDEExiter.CONFIG.WindowTitle)
            return
            
        BlockInput(true)
        try {
            Logger.Log("VDEExiter", "`"F1`" hotkey press recorded; exiting Virtual Desktop")
            ; Open the Virtual Desktop menu
            MouseMove(VDEExiter.CONFIG.OpenMenuButton.x, VDEExiter.CONFIG.OpenMenuButton.y, 0)
            Click
            Sleep(VDEExiter.CONFIG.Delay)
            ; Click on the exit button
            MouseMove(VDEExiter.CONFIG.ExitButton.x, VDEExiter.CONFIG.ExitButton.y, 0)
            Click
            Logger.Log("VDEExiter", "Virtual Desktop exited successfully")
        } catch as err {
            Logger.Log("VDEExiter", "Failed to execute ExitSequence: " err.Message)
            throw Error("Failed to execute ExitSequence: " err.Message)
        } finally {
            BlockInput(false)
        }
    }
}

ExitFunc(reason, code) {
    Logger.Log("VDEExiter", "Stopped")
}

OnExit(ExitFunc)

try {
    Logger.Log("VDEExiter", "Started")
    exiter := VDEExiter()
    ; Bind the exit sequence to the F1 hotkey
    Hotkey("F1", exiter.ExitSequence.Bind(exiter))
} catch as err {
    Logger.Log("VDEExiter", "Failed to initialize: " err.Message)
    throw Error("Failed to initialize VDEExiter: " err.Message)
}
