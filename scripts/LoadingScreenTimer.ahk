#Requires AutoHotkey v2.0.18
#SingleInstance Force
Persistent
#Include ..\utils\Logger.ahk

class LoadingScreenTimer {
    static TIMEOUT_MS := 600000  ; 10 minutes
    static CSV_FILE := A_ScriptDir "\..\data\measurements.csv"

    __New() {
        this.startTime := A_TickCount
        this._InitCsv()
        this.lastId := this._GetLastId()
        this._SetupHotkey()
        this._SetupTimeout()
        Logger.Log("LoadingScreenTimer", "Timer started")
        ; Show an info message box that closes after 3 seconds
        MsgBox(
            "Loading screen timer started.`nPress Alt + F1 to stop the timer.", 
            "LoadingScreenTimer", 
            "0x40000 Iconi T3"  ; Always-on-top with 3 seconds timeout
        )
    }

    _InitCsv() {
        ; Create the data directory and the CSV file if they don't exist
        if !DirExist(A_ScriptDir "\..\data")
            DirCreate(A_ScriptDir "\..\data")
        if !FileExist(LoadingScreenTimer.CSV_FILE)  ; Use static property correctly
            FileAppend("ID,Date,Time,Duration`n", LoadingScreenTimer.CSV_FILE)
    }

    _GetLastId() {
        ; Read the last ID from the CSV file
        try {
            lastLine := ""
            Loop Read, LoadingScreenTimer.CSV_FILE {
                if (A_Index > 1)  ; Skip header
                    lastLine := A_LoopReadLine
            }
            if (lastLine != "") {
                lastId := Integer(StrSplit(lastLine, ",")[1])
                return lastId
            }
        } catch as err {
            Logger.Log("LoadingScreenTimer", "Error reading last ID: " err.Message)
            throw Error("Failed to read last ID from CSV file.")
        }
        return 0  ; Only for empty file with header
    }

    _SaveMeasurement(duration) {
        try {
            ; Increment the ID and get the current date and time
            this.lastId++
            date := FormatTime(, "dd.MM.yyyy")
            time := FormatTime(, "HH:mm:ss")     
            ; Append the measurement to the CSV file with the current date and time
            FileAppend(Format("{1},{2},{3},{4}`n", this.lastId, date, time, duration), LoadingScreenTimer.CSV_FILE)  ; Use static property correctly
            Logger.Log("LoadingScreenTimer", "Measurement saved to CSV")
        } catch as err {
            Logger.Log("LoadingScreenTimer", "Failed to save to CSV: " err.Message)
        }
    }

    _SetupHotkey() {
        Hotkey "~!F1", this._StopTiming.Bind(this)  ; ! is Alt
    }

    _SetupTimeout() {
        timeoutFn := this._CheckTimeout.Bind(this)
        SetTimer(timeoutFn, 1000)
    }

    _CheckTimeout() {
        if (A_TickCount - this.startTime > LoadingScreenTimer.TIMEOUT_MS) {
            Logger.Log("LoadingScreenTimer", "Timer wasn't stopped in time")
            ExitApp()
        }
    }

    _StopTiming(*) {
        elapsedTime := A_TickCount - this.startTime
        
        ; Calculate the duration in minutes, seconds, and centiseconds
        minutes := Floor(elapsedTime / 60000)
        seconds := Floor(Mod(elapsedTime, 60000) / 1000)
        centiseconds := Round(Mod(elapsedTime, 1000) / 10)
        
        ; Format the duration as a string
        timeStr := Format("{:02}:{:02}:{:02}", minutes, seconds, centiseconds)
        Logger.Log("LoadingScreenTimer", "Timer stopped")
        Logger.Log("LoadingScreenTimer", "Loading screen duration: " timeStr)
        
        ; Save measurement to CSV
        this._SaveMeasurement(timeStr)
        
        ; Show an info message box that closes after 3 seconds
        MsgBox(
            "Measurement finished successfully.`n"
            . "Loading screen duration: " timeStr "`n"
            . "Result saved to " LoadingScreenTimer.CSV_FILE,  
            "LoadingScreenTimer",
            "0x40000 Iconi T3"  ; Always-on-top with 3 seconds timeout
        )

        ExitApp()
    }
}

ExitFunc(reason, code) {
    Logger.Log("LoadingScreenTimer", "Stopped")
}

OnExit(ExitFunc)

try {
    Logger.Log("LoadingScreenTimer", "Started")
    timer := LoadingScreenTimer()
} catch as err {
    Logger.Log("LoadingScreenTimer", "Critical error: " err.Message)
    throw Error("Failed to initialize LoadingScreenTimer: " err.Message)
}
