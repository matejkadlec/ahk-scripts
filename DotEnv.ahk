#Requires AutoHotkey v2.0.18
#Include %A_ScriptDir%\Logger.ahk

class DotEnv {
    static vars := Map()

    static Load() {
        envPath := A_ScriptDir "\.env"

        ; Check if the .env file exists
        if !FileExist(envPath) {
            Logger.Log("DotEnv", ".env file not found")
            throw Error(".env file not found")
        }
        
        ; Read the .env file and store the key-value pairs in the vars map
        Loop Read, envPath {
            if (A_LoopReadLine = "" || SubStr(A_LoopReadLine, 1, 1) = "#")
                continue
                
            if (pos := InStr(A_LoopReadLine, "=")) {
                key := Trim(SubStr(A_LoopReadLine, 1, pos - 1))
                value := Trim(SubStr(A_LoopReadLine, pos + 1))
                
                if (SubStr(value, 1, 1) = '"' && SubStr(value, -1) = '"')
                    value := SubStr(value, 2, StrLen(value) - 2)
                    
                DotEnv.vars[key] := value
            }
        }
    }

    static Get(key) {
        return DotEnv.vars.Has(key) ? DotEnv.vars[key] : ""
    }
}
