#Requires AutoHotkey v2.0.18
#SingleInstance Force
Persistent

SCRIPT_NAME := "VDEExiter"
VDE_WINDOW_TITLE := "Virtual Desktop Environment"
MONITOR_OFFSET := 1920
OPEN_MENU_BUTTON := { x: Round(A_ScreenWidth * (940 / 1920)) + MONITOR_OFFSET, y: 5 }
EXIT_BUTTON := { x: Round(A_ScreenWidth * (690 / 1920)) + MONITOR_OFFSET, y: 25 }
CLICK_DELAY_MS := 500
LOG_DIR := A_ScriptDir "\..\logs"
LOG_FILE_MAX_BYTES := 1024 * 1024

try {
    LogMessage(SCRIPT_NAME, "Started")
    Hotkey("F1", ExitVirtualDesktop)
} catch as err {
    LogMessage(SCRIPT_NAME, "Failed to initialize: " err.Message)
    throw Error("Failed to initialize " SCRIPT_NAME ": " err.Message)
}

ExitFunc(reason, code) {
    global SCRIPT_NAME
    LogMessage(SCRIPT_NAME, "Stopped")
}

OnExit(ExitFunc)

ExitVirtualDesktop(*) {
    global SCRIPT_NAME, VDE_WINDOW_TITLE, OPEN_MENU_BUTTON, EXIT_BUTTON, CLICK_DELAY_MS

    BlockInput(true)
    try {
        if !WinActive(VDE_WINDOW_TITLE) {
            BlockInput(false)
            Hotkey("F1", "Off")
            Sleep(50)
            SendInput("{F1}")
            SetTimer(() => Hotkey("F1", "On"), -100)
            return
        }

        LogMessage(SCRIPT_NAME, "`"F1`" hotkey press recorded; exiting Virtual Desktop")
        MouseMove(OPEN_MENU_BUTTON.x, OPEN_MENU_BUTTON.y, 0)
        Click
        Sleep(CLICK_DELAY_MS)
        MouseMove(EXIT_BUTTON.x, EXIT_BUTTON.y, 0)
        Click
        LogMessage(SCRIPT_NAME, "Virtual Desktop exited successfully")
    } catch as err {
        LogMessage(SCRIPT_NAME, "Failed to execute exit sequence: " err.Message)
        throw Error("Failed to execute exit sequence: " err.Message)
    } finally {
        BlockInput(false)
    }
}

LogMessage(scriptName, message) {
    global LOG_DIR, LOG_FILE_MAX_BYTES

    try {
        if !DirExist(LOG_DIR)
            DirCreate(LOG_DIR)

        logFile := LOG_DIR "\" FormatTime(, "dd-MM-yyyy") ".log"
        if FileExist(logFile) {
            fileObj := FileOpen(logFile, "r")
            if fileObj {
                size := fileObj.Length
                fileObj.Close()
                if (size >= LOG_FILE_MAX_BYTES)
                    return
            }
        }

        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        FileAppend(Format("[{1}] [{2}] {3}`n", timestamp, scriptName, message), logFile)
    }
}
