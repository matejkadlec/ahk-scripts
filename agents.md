# Agent Instructions

- Keep every AutoHotkey script standalone. Do not add shared includes, utility
  modules, or a central script manager.
- Use AutoHotkey v2 syntax and keep editable configuration constants near the
  top of each script.
- Prefer clear `ahk_exe` and `ahk_class` window selectors over brittle full
  window titles.
- Use `SetTimer` for repeated work instead of blocking infinite loops.
- Keep generated logs, data files, and local `.env` files out of Git.
- Update `README.md` when scripts, hotkeys, configuration, or license details
  change.
- Before committing script edits, run a quick syntax check with AutoHotkey v2
  when available.
