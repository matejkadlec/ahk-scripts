#Requires AutoHotkey v2.0.18
#SingleInstance Force
Persistent

SCRIPT_NAME := "MatchAcceptor"
WINDOW_TITLE := "ahk_class RCLIENT ahk_exe LeagueClientUx.exe"
ACCEPT_BUTTON_IMAGE := A_ScriptDir "\..\img\AcceptButton.png"
CLIENT_WIDTH := 1280
CLIENT_HEIGHT := 720
SEARCH_INTERVAL_MS := 500
CLICK_DELAY_MS := 100
LOG_DIR := A_ScriptDir "\..\logs"
LOG_FILE_MAX_BYTES := 1024 * 1024

try {
    LogMessage(SCRIPT_NAME, "Started")

    if !FileExist(ACCEPT_BUTTON_IMAGE) {
        LogMessage(SCRIPT_NAME, "Accept button image not found: " ACCEPT_BUTTON_IMAGE)
        throw Error("Accept button image not found: " ACCEPT_BUTTON_IMAGE)
    }

    SetTimer(SearchAndAccept, SEARCH_INTERVAL_MS)
} catch as err {
    LogMessage(SCRIPT_NAME, "Failed to initialize: " err.Message)
    throw Error("Failed to initialize " SCRIPT_NAME ": " err.Message)
}

ExitFunc(reason, code) {
    global SCRIPT_NAME
    LogMessage(SCRIPT_NAME, "Stopped")
}

OnExit(ExitFunc)

SearchAndAccept() {
    global SCRIPT_NAME, WINDOW_TITLE, ACCEPT_BUTTON_IMAGE, CLIENT_WIDTH, CLIENT_HEIGHT, CLICK_DELAY_MS

    if !WinExist(WINDOW_TITLE)
        return

    try {
        if ImageSearch(
            &buttonX,
            &buttonY,
            0,
            0,
            CLIENT_WIDTH,
            CLIENT_HEIGHT,
            "*50 " ACCEPT_BUTTON_IMAGE
        )
        {
            LogMessage(SCRIPT_NAME, "Accept button found")
            BlockInput(true)
            try {
                MouseMove(buttonX + 46, buttonY + 12, 0)
                Sleep(CLICK_DELAY_MS)
                Click
                LogMessage(SCRIPT_NAME, "Accept button clicked")
            } finally {
                BlockInput(false)
            }
        }
    } catch as err {
        LogMessage(SCRIPT_NAME, "ImageSearch failed: " err.Message)
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
