#Requires AutoHotkey v2.0.18
#SingleInstance Force
Persistent
#Include utils\Logger.ahk
#Include utils\DotEnv.ahk

; Add script to Windows Registry startup using short paths to handle spaces
try {
    if !RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "ScriptManager") {
        ; Convert paths to short format (8.3)
        shortAhkPath := FileExist(A_AhkPath) ? GetShortPathName(A_AhkPath) : A_AhkPath
        shortScriptPath := FileExist(A_ScriptFullPath) ? GetShortPathName(A_ScriptFullPath) : A_ScriptFullPath
        
        ; Build command with short paths
        startupCommand := Format('"{1}" "{2}"', shortAhkPath, shortScriptPath)
        
        ; Write to registry
        RegWrite(startupCommand, "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "ScriptManager")
        Logger.Log("ScriptManager", "Successfully added to startup")
    }
} catch as err {
    Logger.Log("ScriptManager", "Registry error: " err.Message)
    throw Error("Registry error: " err.Message)
}

GetShortPathName(longPath) {
    buf := Buffer(260 * 2, 0)  ; 260 is MAX_PATH
    if DllCall("GetShortPathNameW", "Str", longPath, "Ptr", buf, "UInt", 260)
        return StrGet(buf)
    return longPath
}

DotEnv.Load()

class ScriptManager {
    ; Define the configuration for the script manager
    static CONFIG := {
        CheckInterval: 5000,
        Scripts: [
            {
                ScriptPath: A_ScriptDir "\scripts\MatchAcceptor.ahk",
                WindowTitle: "ahk_class RCLIENT ahk_exe LeagueClientUx.exe",
                ScriptType: "Regular",
            },
            {
                ScriptPath: A_ScriptDir "\scripts\LoadingScreenTimer.ahk",
                WindowTitle: "ahk_class RiotWindowClass ahk_exe League of Legends.exe",
                ScriptType: "One-Time",
            },
            {
                ScriptPath: A_ScriptDir "\scripts\VDEExiter.ahk",
                WindowTitle: DotEnv.Get("VDE_WINDOW_TITLE"),
                ScriptType: "Regular",
            }
        ],
    }

    __New() {
        ; Initialize the script PIDs map and set the check timer
        this.scriptPids := Map()
        this.checkTimerFn := this._CheckScripts.Bind(this)
        OnExit(this._OnExit.Bind(this))
    }

    Init() {
        Logger.Log("ScriptManager", "Started")
        SetTimer(this.checkTimerFn, ScriptManager.CONFIG.CheckInterval)
    }

    _CheckScripts() {
        for script in ScriptManager.CONFIG.Scripts {
            scriptName := StrSplit(script.ScriptPath, "\").Pop()

            if WinExist(script.WindowTitle) {
                ; Check if the script should be started
                if !this.scriptPids.Has(scriptName) {
                    Logger.Log("ScriptManager", "Starting " scriptName " [" script.ScriptType "]")
                    pid := this._LaunchScript(script)
                    if pid {
                        this.scriptPids[scriptName] := pid
                    }
                ; Check if the script is still running
                } else if !ProcessExist(this.scriptPids[scriptName]) {
                    if script.ScriptType == "One-Time" {
                        ; For one-time scripts; log that they were closed and update the type
                        Logger.Log("ScriptManager", "Closing " scriptName " [" script.ScriptType "]")
                        script.ScriptType := "One-Time-Closed"
                    } else if script.ScriptType == "Regular" {
                        ; For regular scripts; delete the old PID and start them again
                        this.scriptPids.Delete(scriptName)
                        Logger.Log("ScriptManager", "Starting " scriptName " [" script.ScriptType "]")
                        pid := this._LaunchScript(script)
                        if pid {
                            this.scriptPids[scriptName] := pid
                        }
                    }
                }
            ; WindowTitle no longer exists
            } else if this.scriptPids.Has(scriptName) {
                ; For regular scripts; log that they were closed
                if script.ScriptType == "Regular"
                    Logger.Log("ScriptManager", "Closing " scriptName " [" script.ScriptType "]") 
                ; For one-time scripts; reset the type
                else if script.ScriptType == "One-Time-Closed"
                    script.ScriptType := "One-Time"
                ; For all scripts; close the process and remove it from the map
                ProcessClose(this.scriptPids[scriptName])
                this.scriptPids.Delete(scriptName)
            }
        }
    }

    _LaunchScript(script) {
        ; Launch the script and return its PID
        try {
            Run('"' A_AhkPath '" "' script.ScriptPath '"',, "Hide", &pid)
            return pid
        }
        Logger.Log("ScriptManager", "Failed to launch script: " script.ScriptPath)
        return 0
    }

    _OnExit(reason, code) {
        ; Close all running scripts
        for script in ScriptManager.CONFIG.Scripts {
            scriptName := StrSplit(script.ScriptPath, "\").Pop()
            if this.scriptPids.Has(scriptName) {
                Logger.Log(RegExReplace(scriptName, "\.ahk$"), "Stopped")
                Logger.Log("ScriptManager", "Closing " scriptName " [" script.ScriptType "]")
                ProcessClose(this.scriptPids[scriptName])
                this.scriptPids.Delete(scriptName)
            }
        }
        Logger.Log("ScriptManager", "Stopped")
    }
}

; Initialize and run
try {
    manager := ScriptManager()
    manager.Init()
} catch as err {
    Logger.Log("ScriptManager", "Critical error: " err.Message)
    throw Error("Failed to initialize ScriptManager: " err.Message)
}
