# AutoHotkey Scripts Collection

[![AHK Version](https://img.shields.io/badge/AHK-v2.0.18-blue.svg)](https://www.autohotkey.com/)
[![Windows](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-GPL--3.0-green.svg)](LICENSE)

Standalone Windows automation scripts built with AutoHotkey v2.

## Quick Start

1. Install [AutoHotkey v2.0](https://www.autohotkey.com/).
2. Clone this repository:
   ```bash
   git clone https://github.com/matejkadlec/ahk-scripts.git
   ```
3. Run the script you want directly.

There is no script manager and no shared AutoHotkey utility layer. Each `.ahk`
file owns its own configuration, hotkeys, timers, and logging.

## Scripts

### HytaleAttack

Spams left-click attacks while enabled.

- `R` toggles auto-attack mode.
- Hold left mouse button while enabled to click repeatedly.
- `F3` pauses or resumes the `R` toggle while typing.
- Configure `spamIntervalMs` near the top of the file.

### MatchAcceptor

Automates League of Legends match acceptance.

- Watches for the League client window:
  `ahk_class RCLIENT ahk_exe LeagueClientUx.exe`
- Searches for `img/AcceptButton.png` every 500 ms.
- Clicks the detected accept button.
- Edit constants at the top of `scripts/MatchAcceptor.ahk` to adjust image path,
  client size, search interval, and click delay.

The League client must be visible on screen for image detection to work.

### LoadingScreenTimer

Measures League of Legends loading screen duration.

- Starts timing when the script is launched.
- `Alt + F1` stops the timer.
- Auto-stops after 10 minutes if not stopped manually.
- Saves measurements to `data/measurements.csv`.
- Edit constants at the top of `scripts/LoadingScreenTimer.ahk` to change paths
  and timeout behavior.

### VDEExiter

Provides a quick exit action for a Virtual Desktop Environment window.

- `F1` opens the VDE menu and clicks the configured exit button while the VDE
  window is active.
- If the VDE window is not active, `F1` is passed through normally.
- Edit constants at the top of `scripts/VDEExiter.ahk` to configure the target
  window title, monitor offset, click coordinates, and click delay.

## Logging And Data

Scripts that log write to `logs/dd-mm-yyyy.log`. Generated logs and timer data
are ignored by Git.

## Troubleshooting

- Use AutoHotkey Window Spy to confirm `ahk_class` and `ahk_exe` values.
- Prefer `ahk_class` or `ahk_exe` identifiers over full window titles.
- Avoid `ahk_pid` and `ahk_id` in saved configuration because those values
  change every session.
- If image recognition fails, update `img/AcceptButton.png` if Riot changes the
  button appearance.
- If clicks land on the wrong monitor, adjust coordinate and monitor-offset
  constants at the top of the affected script.

## Development

- Keep scripts standalone: do not add shared AutoHotkey includes or a central
  launcher.
- Put editable constants near the top of each script.
- Use AutoHotkey v2 syntax.
- Document new scripts in this README.
- Visual Studio Code with the AHK++ extension is recommended for editing.
