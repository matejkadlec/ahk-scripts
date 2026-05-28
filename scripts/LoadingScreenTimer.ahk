#Requires AutoHotkey v2.0.18
#SingleInstance Force
Persistent

SCRIPT_NAME := "LoadingScreenTimer"
TIMEOUT_MS := 600000
CSV_FILE := A_ScriptDir "\..\data\measurements.csv"
LOG_DIR := A_ScriptDir "\..\logs"
LOG_FILE_MAX_BYTES := 1024 * 1024

startTime := 0
lastId := 0
timeoutTimerFn := unset

try {
    LogMessage(SCRIPT_NAME, "Started")
    StartTiming()
} catch as err {
    LogMessage(SCRIPT_NAME, "Critical error: " err.Message)
    throw Error("Failed to initialize " SCRIPT_NAME ": " err.Message)
}

ExitFunc(reason, code) {
    global SCRIPT_NAME
    LogMessage(SCRIPT_NAME, "Stopped")
}

OnExit(ExitFunc)

StartTiming() {
    global SCRIPT_NAME, startTime, lastId, timeoutTimerFn

    startTime := A_TickCount
    InitCsv()
    lastId := GetLastId()
    Hotkey("~!F1", StopTiming)
    timeoutTimerFn := CheckTimeout
    SetTimer(timeoutTimerFn, 1000)

    LogMessage(SCRIPT_NAME, "Timer started")
    MsgBox(
        "Loading screen timer started.`nPress Alt + F1 to stop the timer.",
        SCRIPT_NAME,
        "0x40000 Iconi T3"
    )
}

InitCsv() {
    global CSV_FILE

    SplitPath(CSV_FILE, , &dataDir)
    if !DirExist(dataDir)
        DirCreate(dataDir)
    if !FileExist(CSV_FILE)
        FileAppend("ID,Date,Time,Duration`n", CSV_FILE)
}

GetLastId() {
    global CSV_FILE, SCRIPT_NAME

    try {
        lastLine := ""
        Loop Read, CSV_FILE {
            if (A_Index > 1)
                lastLine := A_LoopReadLine
        }
        if (lastLine != "")
            return Integer(StrSplit(lastLine, ",")[1])
    } catch as err {
        LogMessage(SCRIPT_NAME, "Error reading last ID: " err.Message)
        throw Error("Failed to read last ID from CSV file.")
    }

    return 0
}

SaveMeasurement(duration) {
    global CSV_FILE, SCRIPT_NAME, lastId

    try {
        lastId++
        date := FormatTime(, "dd.MM.yyyy")
        time := FormatTime(, "HH:mm:ss")
        FileAppend(Format("{1},{2},{3},{4}`n", lastId, date, time, duration), CSV_FILE)
        LogMessage(SCRIPT_NAME, "Measurement saved to CSV")
    } catch as err {
        LogMessage(SCRIPT_NAME, "Failed to save to CSV: " err.Message)
    }
}

CheckTimeout() {
    global SCRIPT_NAME, TIMEOUT_MS, startTime

    if (A_TickCount - startTime > TIMEOUT_MS) {
        LogMessage(SCRIPT_NAME, "Timer was not stopped in time")
        ExitApp()
    }
}

StopTiming(*) {
    global SCRIPT_NAME, CSV_FILE, startTime, timeoutTimerFn

    elapsedTime := A_TickCount - startTime
    minutes := Floor(elapsedTime / 60000)
    seconds := Floor(Mod(elapsedTime, 60000) / 1000)
    centiseconds := Round(Mod(elapsedTime, 1000) / 10)
    timeStr := Format("{:02}:{:02}:{:02}", minutes, seconds, centiseconds)

    if IsSet(timeoutTimerFn)
        SetTimer(timeoutTimerFn, 0)

    LogMessage(SCRIPT_NAME, "Timer stopped")
    LogMessage(SCRIPT_NAME, "Loading screen duration: " timeStr)
    SaveMeasurement(timeStr)

    MsgBox(
        "Measurement finished successfully.`n"
        . "Loading screen duration: " timeStr "`n"
        . "Result saved to " CSV_FILE,
        SCRIPT_NAME,
        "0x40000 Iconi T3"
    )

    ExitApp()
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
