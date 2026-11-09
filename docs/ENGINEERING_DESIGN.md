# 工程设计导航

本文件回答“改什么、读哪里、有哪些合同”。当前活跃实现为 [source/AutoFarm_v5.ahk](../source/AutoFarm_v5.ahk) 与 [source/AutoSpace_v1.ahk](../source/AutoSpace_v1.ahk)；AutoSpace 合同见 [AutoSpace 模块](modules/autospace/README.md)。历史快照不承载现行合同。

## 1. 实现与快照

| 文件 | 角色 | 阅读条件 |
|---|---|---|
| [source/AutoFarm_v5.ahk](../source/AutoFarm_v5.ahk) | 唯一活跃宏：配置加载、热键同步、四组循环、通知 | 任何行为改动 |
| [source/AutoSpace_v1.ahk](../source/AutoSpace_v1.ahk)、[source/autospace.ini](../source/autospace.ini) | 独立空格连按宏与配置权威；合同见 [AutoSpace 模块](modules/autospace/README.md) | 修改 AutoSpace 行为或配置 |
| [source/autofarm.ini](../source/autofarm.ini) | 配置权威：键名、默认值、行内注释、单位 | 增删键或调整时序/热键 |
| [source/Notify.ahk](../source/Notify.ahk)、[source/Lib/](../source/Lib/) | 第三方通知/GUI 库（上游 Notify 项目） | 只在通知显示或 GUI 问题 |
| [source/Notifytest.ahk](../source/Notifytest.ahk)、[source/Examples.ahk](../source/Examples.ahk)、[source/Notify Creator.ahk](<../source/Notify Creator.ahk>) | 通知库自检、示例与可视化工具 | 升级/修改 Notify 行为 |
| [source/AutoFarm_v3.ahk](../source/AutoFarm_v3.ahk)、[source/AutoFarm_v4.ahk](../source/AutoFarm_v4.ahk)、[source/AutoFarm.ahk](../source/AutoFarm.ahk) | 历史快照，仅参考 | 对照旧实现；不在此开发 |
| [assets/](../assets/) | README 截图 | 更新使用说明配图 |
| [source/Licenses/](../source/Licenses/)、[LICENSE](../LICENSE)、[source/LICENSE](../source/LICENSE) | 第三方与项目许可 | 分发、再发布前 |

## 2. 配置合同

- 读取路径为 `A_ScriptDir "\autofarm.ini"`；`ReadCfg(section, key, default)` 读值后 `Trim`，数值型再 `+0`。
- 段固定为 `[Hotkeys]`、`[Keys]`、`[Timing]`、`[Gather]`；新增键必须同时更新 `source/autofarm.ini`（键 + 注释 + 单位）与脚本内默认值，二者保持一致。
- 默认值在代码与 INI 双写：INI 缺键或文件缺失时用代码默认，因此改动默认值要两处一起改。
- 热键：`SyncOneHotkey` 先 `Hotkey(old, handler, "Off")` 再 `Hotkey(new, handler, "On")`；非法键回滚旧键、`MsgBox` 提示并返回 false，本次不启动。启动时同步失败直接 `ExitApp`。
- `[Gather] IntervalMs` 小于 1000 时回落为 10000。
- 配置实时性：每次开启任一循环前调用 `ReloadConfig()`；已运行的循环使用开启时读到的值，不会在循环中途热更新。
- 段位不通用：`JadeInterval` 读自 `[Timing]` 的 `JadeIntervalMs`，写在 `[Keys]` 不会生效。热键名与键名同理，分别来自 `[Hotkeys]` 和 `[Keys]`。
- AutoSpace 配置见 [模块页](modules/autospace/README.md)。

## 3. 模式状态机

- 四个布尔：`autofarm`（毒塔/刷宝）、`autobeef`（牛筋）、`autojade`（独山玉）、`autogather`（采集）。
- 互斥：farm/beef/jade 开启任一会停掉其余两个并发送停止通知；三者开启时调用 `StopGatherIfNeeded()`；采集开启会停掉三者。
- 主 `Loop` 每轮开头按 `autofarm → autobeef → jade` 取 `currentMode` 快照，关闭后当前轮仍走完；jade 用 `InterruptibleSleepAccurate(…, "jade")` 每 100 ms 检查开关以便尽快退出。
- farm：初始等待 → 飒踏流星按住 `MeteorHoldMs` → 轻点 → 等待 `BeforeMightyDropMs` → 千斤坠 → 等待 `BeforeDragonsBreathMs` → 神龙吐火 → `AfterDragonsBreathMs`；治疗在开启时立即释放一次，之后每 `HealCooldownMs` 检查。
- beef：飒踏流星 → 千斤坠 → 灵虚一指 ×`TouchOfDeathCount` → 拾取（`AfterLootMs`）。
- jade：`JadeStartDelayMs` → 陌刀特殊技 → `AfterMoSpecialMs` → 闪避归位 → `JadeIntervalMs`（默认 300000）后进入下一轮。
- gather：按 `[Gather] IntervalMs` 定时点击 `Key`；按下时长用 `TapMs`。
- AutoSpace：`autoSpace` 布尔；开启后按 `KeyPressGap` 间隔发送空格 down/up（`TapMs`），等待分片检查开关；`-`/`=` 仅运行中注册。见 [模块页](modules/autospace/README.md)。

## 4. 通知合同

- `ShowNotify(tag, title, message, color, sound)` 先按 `tag` 关闭旧通知，再 `Notify.Show(...)`（主题 `Aurora`、`dur=3`、微软雅黑）。
- 标签固定为 `AutoFarmToggle`、`AutoBeefToggle`、`AutoJadeToggle`、`AutoGatherToggle`；改标题/颜色/声音时四处保持同类风格。
- AutoSpace 标签：`AutoSpaceToggle`（开/停）、`AutoSpaceGap`（调整后显示新间隔）。
- 通知库来自上游 Notify 项目，说明见 [source/README.md](../source/README.md)；升级前读其 JSDoc 与 `Examples.ahk`。

## 5. 权限与输入

- 非管理员启动时 `Run '*RunAs "' A_ScriptFullPath '"'` 自提权后退出；不要新增提权路径或绕过。
- 发送统一走 `SendEvent` 的 down/up（`TapKey`、`HoldKey`、`RepeatTap`）；所有时长来自 INI，不写死新常量。
- `$F1::return` 永久屏蔽 F1；默认占用 F7–F10 作为四组开关。
- AutoSpace 同样自提权；默认 F9 与 AutoFarm 刷宝冲突，不同时运行。

## 6. 变更落点

| 要改什么 | 落点 |
|---|---|
| 新增一种循环 | 布尔 + `Toggle*` 函数 + 互斥处理 + 主 `Loop` 分支 + INI 段/键 + README 说明；随后人工验证 |
| 新增/调整时序 | `[Timing]` 键与注释 + `LoadConfig` 读取 + 代码默认值 + README/设计说明 |
| 新增/调整热键 | `[Hotkeys]` 键 + `LoadConfig` + `SyncToggleHotkeys`；确认互斥通知一致 |
| 调整通知显示 | `ShowNotify` 调用点与 `Notify` 主题参数；先跑 `Notifytest.ahk` 人工确认 |
| 修改 AutoSpace 行为 | `source/AutoSpace_v1.ahk` + `source/autospace.ini`；细节见 [模块页](modules/autospace/README.md) |
| 更新用户说明 | `README.md` 功能/配置节；截图放 `assets/` |
