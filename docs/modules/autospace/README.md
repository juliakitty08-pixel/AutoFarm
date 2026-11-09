# AutoSpace v1 模块说明

本页是 AutoSpace 的行为与配置合同；[source/AutoSpace_v1.ahk](../../../source/AutoSpace_v1.ahk) 是唯一实现，[source/autospace.ini](../../../source/autospace.ini) 是配置权威。它独立于 AutoFarm v5 进程，默认都用 `F9`，不同时运行。修改 AutoSpace 或安排验证时读本页。

## 1. 文件与运行

- 实现：[source/AutoSpace_v1.ahk](../../../source/AutoSpace_v1.ahk)
- 配置：[source/autospace.ini](../../../source/autospace.ini)
- 运行：`D:\ScoopApps\apps\autohotkey\current\v2\AutoHotkey64.exe source\AutoSpace_v1.ahk`（需管理员）
- 与 v5 相同，非管理员启动会自提权；发送使用 `SendEvent` 的 down/up。

## 2. 配置合同

- `[Hotkeys] Toggle=F9`、`GapDecrease=-`、`GapIncrease==`；`[Keys] Key=Space`；`[Timing] KeyPressGap=200`、`Adjustment=10`、`TapMs=60`。
- 读取沿用 `ReadCfg`：`Trim` 后数值 `+0`；缺键或文件缺失使用代码默认。
- `LoadConfig()` 在各次开启循环前执行，因此改 INI 后按 Toggle 重开即可生效。
- 代码默认与 INI 双写：`KeyPressGap=200`、`Adjustment=10`、`TapMs=60`。
- `KeyPressGap < 10` 回落到 200；`Adjustment < 1` 回落到 10；`TapMs < 1` 回落到 60。运行中 `KeyPressGap` 下限为 10。
- 关闭循环时把当前 `KeyPressGap` 写回 `[Timing]`。写回用 UTF-8 行级替换，避免 `IniWrite` 按 ANSI 读取破坏中文注释；写失败时通知显示“写入配置失败”。

## 3. 状态与循环

- `autoSpace` 布尔；`Toggle` 热键切换。
- 开启后主循环立即开始：空格 down → `Sleep TapMs` → 空格 up → 等待 `KeyPressGap`；等待以 20ms 分片检查 `autoSpace`，关闭后尽快退出，不再补按。
- `GapDecrease` / `GapIncrease` 只在运行中注册；每次按 `Adjustment` 调整，调整后通知显示新值。停止后释放 `-` / `=`，不再截获这两个键。
- 关闭顺序：置 `autoSpace=false` → 禁用调整热键 → 写回 `KeyPressGap` → 停止通知（含“已写入配置/写入配置失败”）。

## 4. 通知

- 标签：`AutoSpaceToggle`（开始/停止）、`AutoSpaceGap`（调整）。
- 沿用 `ShowNotify`：Aurora 主题、3 秒、微软雅黑；开始绿色，停止红色 + `Windows Restore`；调整显示 `按键间隔 N 毫秒`。

## 5. 冲突与未覆盖

- 默认 `F9` 与 AutoFarm 的刷宝 `F9` 冲突；不要同时运行。需要并用时改 `[Hotkeys] Toggle`。
- 行为验证必须人工完成；`/Validate` 只证明加载期语法。当前状态：语法检查通过，行为 `NOT_RUN`，见[验证导航](../../VALIDATION.md)。
