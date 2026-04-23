# Repository Guidelines

## Project Structure & Module Organization
Core scripts live in `source/`. The latest gameplay macro work is in `source/AutoFarm_v5.ahk`; older snapshots such as `AutoFarm_v3.ahk`, `AutoFarm_v4.ahk`, and `AutoFarm.ahk` should be treated as references unless a change explicitly targets them. Shared helpers and third-party UI libraries live in `source/Lib/`, configuration defaults live in `source/autofarm.ini`, and notification examples live in `source/Notifytest.ahk` and `source/Examples.ahk`. Screenshots used by the top-level README are stored in `assets/`, and bundled license texts are under `source/Licenses/`.

## Build, Test, and Development Commands
This repository does not use a separate build system. Use AutoHotkey v2 on Windows to run scripts directly:

```powershell
AutoHotkey64.exe source\AutoFarm_v5.ahk
AutoHotkey64.exe source\Notifytest.ahk
AutoHotkey64.exe source\Examples.ahk
```

Use the first command for the main macro, `Notifytest.ahk` for notification smoke checks, and `Examples.ahk` when changing the bundled `Notify.ahk` behavior.

## Coding Style & Naming Conventions
Follow the existing AutoHotkey v2 style: 4-space indentation, braces on their own lines for block statements, and concise helper functions. Keep globals and locals in `camelCase`; use descriptive prefixes for timing and key settings such as `msTap`, `healCooldownMs`, and `keyMeteorFlight`. Keep config keys grouped by INI section (`[Hotkeys]`, `[Keys]`, `[Timing]`, `[Gather]`) and preserve the current naming pattern when adding new entries.

## Testing Guidelines
All testing in this repository must be carried out by a human tester on Windows with AutoHotkey v2. Do not add, run, or rely on automated tests, test harnesses, or agent-driven validation for gameplay macros, hotkeys, timing loops, or notification behavior. After each change, have a person launch the affected script, verify hotkey registration, and confirm start/stop notifications, timing-sensitive loops, and config loading from `source/autofarm.ini` behave as expected after a restart.

## Commit & Pull Request Guidelines
Use precise commit subjects in the format `area: summary | detail`. Keep `area` narrow and repo-specific, such as `autofarm`, `notify`, `config`, `readme`, or `assets`. Write the summary as the main change and use the detail clause for scope, behavior, or constraint, for example `autofarm: fix jade loop timing | stop drift after long runs`.

Pull requests should follow the same level of precision: include a short summary, the manual validation performed, and any changed hotkeys, INI keys, or screenshots when UI or README assets were updated.

## Security & Configuration Tips
The main script requests administrator privileges on launch; avoid introducing new elevation paths unless required for input automation. Do not commit personal hotkey mappings or machine-specific settings without updating `source/autofarm.ini` comments to explain the default behavior.
