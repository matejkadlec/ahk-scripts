#Requires AutoHotkey v2.0.18
#SingleInstance Force
Persistent
#Include %A_ScriptDir%\Logger.ahk

class MatchAcceptor {
    static CONFIG := {
        WindowTitle: "ahk_class RCLIENT ahk_exe LeagueClientUx.exe",
        AcceptButtonImage: A_ScriptDir "\img\AcceptButton.png",
        ClientWidth: 1280,
        ClientHeight: 720,
        SearchInterval: 500,
        Delay: 100
    }
    
    __New() {
        ; Check if the accept button image exists
        if !FileExist(MatchAcceptor.CONFIG.AcceptButtonImage) {
            Logger.Log("MatchAcceptor", "Accept button image not found: " MatchAcceptor.CONFIG.AcceptButtonImage)
            throw Error("Accept button image not found")
        }
    }
    
    ; Search for the accept button and click on it if found
    SearchAndAccept() {
        try {            
            ; Look for the accept button
            try {
                if ImageSearch(
                    &buttonX,
                    &buttonY, 
                    0, 
                    0, 
                    MatchAcceptor.CONFIG.ClientWidth, 
                    MatchAcceptor.CONFIG.ClientHeight,
                    "*50 " MatchAcceptor.CONFIG.AcceptButtonImage
                ) 
                {
                    Logger.Log("MatchAcceptor", "AcceptButton found")
                    BlockInput(true)
                    try {
                        ; Click the accept button
                        MouseMove(buttonX + 46, buttonY + 12, 0)
                        Sleep(MatchAcceptor.CONFIG.Delay)
                        Click
                        Logger.Log("MatchAcceptor", "AcceptButton clicked")
                    } finally {
                        BlockInput(false)
                    }
                }
            } catch as err {
                Logger.Log("MatchAcceptor", "ImageSearch failed: " err.Message)
            }
        }
    }
}

ExitFunc(reason, code) {
    Logger.Log("MatchAcceptor", "Stopped")
}

OnExit(ExitFunc)

try {
    Logger.Log("MatchAcceptor", "Started")
    acceptor := MatchAcceptor()
    ; Set timer for search and accept
    SetTimer(acceptor.SearchAndAccept.Bind(acceptor), MatchAcceptor.CONFIG.SearchInterval)
} catch as err {
    Logger.Log("MatchAcceptor", "Failed to initialize: " err.Message)
    throw Error("Failed to initialize MatchAcceptor: " err.Message)
}
