# AutoHotkey Scripts Collection

[![AHK Version](https://img.shields.io/badge/AHK-v2.0.18-blue.svg)](https://www.autohotkey.com/)
[![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-GNU-green.svg)](LICENSE)

Standalone Windows automation scripts built with AutoHotkey v2.

## 📋 Table of Contents
- [Quick Start](#-quick-start)
- [Scripts](#-scripts)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Development](#-development)

## 🚀 Quick Start

### Single Script Usage
1. Download script and dependencies:
   ```
   MyScripts/
   ├── ScriptName.ahk
   ├── Logger.ahk        # Required for all scripts
   └── img/              # Only for MatchAcceptor
       └── AcceptButton.png
   ```
2. Run the `.ahk` file directly

### Full Suite Installation
1. Install [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Clone this repository:
   ```bash
   git clone https://github.com/matejkadlec/ahk-scripts.git
   ```
3. Run `ScriptManager.ahk` to start the automation suite

From now on, the `ScriptManager.ahk` should start automatically on Windows startup.

## 🛠️ Configuration

### DotEnv Component
The `DotEnv.ahk` module manages environment variables:

- Loads variables from `.env` file
- Provides secure storage for sensitive information
- Validates `.env` file existence
- Supports:
  - Empty lines
  - Comments (lines starting with #)
  - Quoted values
- Example `.env` file:
  ```
  VDE_WINDOW_TITLE="Virtual Desktop Environment"
  ```
- Example usage:
  ```ahk
  #Include ..\utils\DotEnv.ahk

  DotEnv().load()
  DotEnv.Get("VDE_WINDOW_TITLE")
  ```
- Using `DotEnv.ahk` is optional - you can always use window title directly in the code.

### Logger Component
The `Logger.ahk` module provides centralized logging functionality:

- Log Location: `logs/dd-mm-yyyy.log`
- Features:
  - Automatic directory creation
  - Daily log rotation
  - 1 MB size limit with warnings
  - Thread-safe operation
- Entry Format: `[yyyy-MM-dd HH:mm:ss] [ScriptName] Message`
- Automatic initialization on import
- Log files older than 3 days (including today) are being automatically deleted 
  - You can change the `AGE_LIMIT` in `Logger.ahk` to your preference
  - If you don't want to automatically delete log files at all, set `AGE_LIMIT` to -1

### Script Manager
The `ScriptManager.ahk` serves as the central control system:

- Script Lifecycle Management:
  - Launches scripts automatically based on window presence
  - Monitors processes and restarts on crash
  - Ensures clean process termination
- Windows Registry Integration:
  - Automatic startup registration
  - Handles paths with spaces correctly
- Configurable monitoring interval (default: 5000ms)
- All running child scripts are closed when this script is closed/reloaded

## 📜 Scripts

### MatchAcceptor
**Purpose**: Automates League of Legends match acceptance

**Features**:
- Monitors the screen every 500ms
- Clicks the __ACCEPT__ button automatically when detected
- Compatible with both LoL and TFT queues
- Optimized for default client resolution (1280x720)

**Note**: The League client must be the active window when a match is found. If needed, simply click anywhere in the client to activate it.

### LoadingScreenTimer
**Purpose**: Measures League of Legends loading screen duration

**Features**:
- Starts timing automatically when loading screen appears
- Stops timing when `Alt + F1` hotkey is pressed
- Auto-stops after 10 minutes if `Alt + F1` isn't pressed
- Info message boxes integration 
- Displays time in MM:SS:CC format (minutes:seconds:centiseconds)
- Records measurements in CSV format with:
  - Auto-incrementing ID
  - Date (dd.MM.yyyy)
  - Time (HH:mm:ss)
  - Duration (MM:SS.CC)
- Also works with TFT loading screen


**Note**: The timer begins automatically when the game window appears. Press `Alt + F1` right after the game starts to stop the timing manually. Measurements are saved to `data/measurements.csv`. If `Alt + F1` isn't pressed, the timer stops automatically after 10 minutes.

### VDEExiter
**Purpose**: Provides quick exit for Virtual Desktop Environment
 
**Features**:
- Activates with `F1` hotkey (only while in VDE)
- Automatically opens VDE menu and clicks on exit button
- Includes error handling and logging

**Note**: To use `DotEnv.ahk`, create a `.env` file in the root directory with the `VDE_WINDOW_TITLE` variable.

## 🐞 Troubleshooting

### Common Issues
- **Scripts not starting**: Use AutoHotkey Window Spy to verify the correct window title
  - It's not recommended to use window title directly for possible ambiguity
  - Use `ahk_class` or `ahk_exe` identifiers instead
  - Avoid using `ahk_pid` and `ahk_id` completely, these values are session-specific 
- **Logging issues**: Confirm `Logger.ahk` is in the correct directory
- **Image recognition fails**: Verify image path and update `AcceptButton.png` if Riot changes the button look
- **DotEnv errors**: Verify `.env` file location, formatting, and variable names/values

## 🧪 Development

### Contributing

Contributions are welcome! Any working AHK v2 script can be added. Please follow these guidelines:

1. Implement logging using `Logger.ahk`
2. Provide descriptive documentation in this file
3. Maintain consistent code style
4. Submit pull requests with clear descriptions
5. I recommend you to use Visual Studio Code with AHK++ extension for coding in AHK
