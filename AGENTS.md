# AutoFarm 仓库规则

本文件只保存项目稳定约束、入口和例外；通用开发、文档与会话流程见全局 `AGENTS.md` 及其引用技能。

## 唯一入口与阅读

- 当前状态与下一任务：`docs/DEVELOPMENT.md`（唯一入口，先读第 1、2、5、7 节）。
- 设计落点：`docs/ENGINEERING_DESIGN.md`；验证资格：`docs/VALIDATION.md`；历史：`docs/history/`；证据：`docs/evidence/`；维护记录：`docs/maintenance/`。
- `README.md` 是面向用户的安装/功能/配置说明，不承载开发状态；用户可见的版本历史在 `docs/history/release-notes.md`。
- 仓库无既有编号体系：任务用任务名或日期标识。

## 项目结构与权威路径

- 活跃实现：`source/AutoFarm_v5.ahk`。`source/AutoFarm_v3.ahk`、`source/AutoFarm_v4.ahk`、`source/AutoFarm.ahk` 只是参考快照，除非用户明确要求，不修改。
- 配置权威：`source/autofarm.ini`（键名、默认值、注释、单位）。改动脚本默认值必须同步该文件。
- 共享与第三方：`source/Lib/`、`source/Notify.ahk`、`source/Icons.dll`；通知示例与自检：`source/Examples.ahk`、`source/Notifytest.ahk`、`source/Notify Creator.ahk`；上游说明：`source/README.md`。
- README 截图：`assets/`；许可：`LICENSE`、`source/LICENSE`、`source/Licenses/`。

## 运行、测试与验证

- 无构建系统；用 AutoHotkey v2 在 Windows 直接运行：
  - `AutoHotkey64.exe source\AutoFarm_v5.ahk`（主宏，需管理员）
  - `AutoHotkey64.exe source\Notifytest.ahk`（通知冒烟）
  - `AutoHotkey64.exe source\Examples.ahk`（Notify 示例）
- 硬约束：所有测试必须由人工在 Windows + AutoHotkey v2 上完成。不得添加、运行或依赖自动化测试、测试脚手架或 agent 驱动的验证，覆盖游戏宏、热键、时序循环与通知行为。
- 每次改动后由人启动受影响脚本，确认热键注册、开始/停止通知、时序循环，以及 `source/autofarm.ini` 加载（重启或热键重启循环后）符合预期。
- 资格定义与未覆盖范围见 `docs/VALIDATION.md`。

## 代码风格与命名

- AutoHotkey v2 风格：4 空格缩进，块语句大括号独占一行，函数保持短小。
- 全局/局部变量用 `camelCase`；时间与按键使用描述性前缀，如 `msTap`、`healCooldownMs`、`keyMeteorFlight`。
- INI 键按 `[Hotkeys]`、`[Keys]`、`[Timing]`、`[Gather]` 分组，沿用现有命名模式。

## 配置约定

- 新增或调整配置键：同时更新 `source/autofarm.ini`（键、注释、单位）与 `source/AutoFarm_v5.ahk`（全局变量、`LoadConfig` 读取、代码默认值），两处默认值必须一致。
- 用户可见行为变化同步到 `README.md` 的对应说明，不要只改代码。
- 不提交个人热键或机器专属设置，除非同时更新 `source/autofarm.ini` 注释说明默认行为。

## Git 身份与提交（项目例外）

- 本仓库固定使用 GitHub 身份 `juliakitty08-pixel <juliakitty08@gmail.com>`，与全局默认 `harrywenjie <harrywenjie@gmail.com>` 不同。提交与推送都使用本地仓库配置的身份。
- 凭据：`credential.helper=store --file=.git/local-credentials`，含明文令牌，不进入 Git、不回显、不复制到别处。
- `gh` CLI 当前登录 `harrywenjie`，不是本仓库身份：不要用 `gh` 推送，也不要用它的仓库权限字段判断本仓库能否推送。
- 2026-11-09 已核实该令牌属于 `juliakitty08-pixel` 且对仓库有 admin/push 权限，详见 `docs/evidence/2026-11-09-github-identity-verification.md`。更换远端、身份或令牌后重新核实。
- 提交格式：`area: summary | detail`，`area` 取 `autofarm`、`notify`、`config`、`readme`、`docs`、`assets` 等窄范围；示例 `autofarm: fix jade loop timing | stop drift after long runs`。
- PR 说明包含简短摘要、实际人工验证内容，以及变更的热键、INI 键或截图（涉及 UI/README 资产时）。

## 文档维护绑定

- 按全局 `AGENTS.md` §6 与 `doc-governance` 技能维护：单一入口、按需阅读、容量预警（沿用默认 8,000 / 4,000 / 6,000 LF 字符）、整体复审、未决项保留、历史不覆盖现行合同。
- 每轮触及文档时只更新入口、设计/验证导航和相关主题正文的必要部分；不新增并行 TODO、ROADMAP、STATUS、“最新版”或仓库内交接文档。
- 文档维护/迁移过程写入 `docs/maintenance/`；版本历史写入 `docs/history/`；身份/权限核实写入 `docs/evidence/`。
- 临时文件放 `temp/<任务名>/`（已被 `.gitignore` 忽略），不进入提交。

## 安全与提权

- 主脚本启动时请求管理员权限；不要新增提权路径，除非输入自动化确实需要。
- 输入发送保持 `SendEvent` + down/up 模式；时序值从 INI 读取，不写死新常量。
