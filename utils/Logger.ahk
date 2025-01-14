#Requires AutoHotkey v2.0.18

class Logger {
    static LOGS_DIR := ""
    static logFile := ""
    static MAX_SIZE := 1024 * 1024  ; 1 MB in bytes
    static AGE_LIMIT := 3  ; Delete files older than 3 days

    static Init() {
        ; Make sure the correct logs directory is used
        if InStr(A_ScriptDir, "\scripts")
            Logger.LOGS_DIR := A_ScriptDir "\..\logs"
        else 
            Logger.LOGS_DIR := A_ScriptDir "\logs"
        

        ; Create log directory if it doesn't exist
        if !FileExist(Logger.LOGS_DIR)
            DirCreate(Logger.LOGS_DIR)
        
        ; Create log file if it doesn't exist
        Logger.logFile := Format("{1}\{2}.log", Logger.LOGS_DIR, FormatTime(, "dd-MM-yyyy"))
        if !FileExist(Logger.logFile)
            FileAppend("", Logger.logFile)
            
        ; Cleanup old log files; -1 means no age limit
        if Logger.AGE_LIMIT != -1
            Logger.CleanupOldLogs()
    }
    
    static CheckSize() {
        if !FileExist(Logger.logFile)
            return
            
        fileObj := FileOpen(Logger.logFile, "r")
        if !fileObj
            return
            
        size := fileObj.Length
        fileObj.Close()
        
        if (size >= Logger.MAX_SIZE)
            throw Error("Log file size limit (1MB) reached. Please archive or delete the log file.")
    }
    
    static Log(scriptName, action) {
        if (Logger.logFile = "")
            Logger.Init()
        ; Check if log file size doesn't exceed the limit  
        Logger.CheckSize()
        try {
            ; Log the action with a timestamp
            timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
            FileAppend(Format("[{1}] [{2}] {3}`n", timestamp, scriptName, action), Logger.logFile)
        }
    }
    
    static CleanupOldLogs() {
        if !DirExist(Logger.LOGS_DIR)
            return
            
        ; Calculate cutoff date (exactly 3 days ago)
        cutoffDate := FormatTime(DateAdd(A_Now, -Logger.AGE_LIMIT, "days"), "yyyyMMdd")
            
        loop files Logger.LOGS_DIR "\*.log" {
            ; Convert file date to YYYYMMDD format for direct comparison
            fileDate := FormatTime(A_LoopFileTimeCreated, "yyyyMMdd")
            
            ; Delete if file date is older than or equal to cutoff
            if (fileDate <= cutoffDate)
                FileDelete(A_LoopFilePath)
        }
    }
}

try {
    Logger.Init()
} catch as err {
    throw Error("Failed to initialize Logger: " err.Message)
}
