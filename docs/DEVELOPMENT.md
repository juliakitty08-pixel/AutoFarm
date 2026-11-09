# AutoFarm 统一开发入口

这是唯一维护当前状态和下一任务卡的入口。先读第 1、2、5、7 节，按本轮目标核对第 3 节范围，再按阅读条件进入相关章节。主设计、验证、模块指南与历史索引均非默认全文必读。

## 1. 当前快照

**当前目标：** 维护 AutoFarm v5 自动刷宝/采集宏：保持 `source/AutoFarm_v5.ahk` 与 `source/autofarm.ini` 的热键、时序、四组循环可用，并让 README 使用说明与配置权威保持一致。

**非目标：** 不新增游戏内循环或技能分支，不重构宏逻辑，不引入自动化测试或模拟输入。

**当前焦点：** 文档结构规范化（2026-11-09）已完成；下一步是确认 README 配置示例的覆盖范围（见第 3、5 节）。

**最近验证交付：** 2026-11-09 文档结构迁移：相对链接、文件存在性、容量与单一入口静态检查通过；宏行为未在本轮验证（`NOT_RUN`，需人工，见[验证导航](VALIDATION.md)）。

**部署/运行基线：** GitHub 最新发布为 `v5`（Release「脚本V5」，2026-04-23T01:29:51Z）；2026-11-09 文档迁移提交前的 `main` 基线为 `4e67a36`（2026-04-23）。运行环境 Windows + AutoHotkey v2，脚本启动时自请求管理员权限。

**当前阻塞：** 无已知阻塞。已知未决项：README 配置示例的覆盖范围待确认——目前只列常用键，完整键位指向 INI（第 5 节 OPEN）。

## 2. 权威资料与阅读条件

| 需要什么 | 阅读位置 | 阅读条件 |
|---|---|---|
| 用户安装、热键、站位与配置说明 | [README.md](../README.md) | 面向用户说明或核对默认行为时 |
| 配置键名、默认值与行内注释 | [source/autofarm.ini](../source/autofarm.ini) | 增删配置键或调整默认值时必须先读 |
| 项目稳定约束、提交与身份规则 | [AGENTS.md](../AGENTS.md) | 每轮开始 |
| 当前实现结构与变更落点 | [工程设计导航](ENGINEERING_DESIGN.md) | 修改脚本、配置或通知行为时 |
| 人工验证资格与未覆盖范围 | [验证导航](VALIDATION.md) | 需要声明“已验证”或安排验证时 |
| 版本历史与旧功能说明 | [history/release-notes.md](history/release-notes.md) | 需要追溯发布内容时，不默认加载 |
| GitHub 身份与权限核实 | [evidence/2026-11-09-github-identity-verification.md](evidence/2026-11-09-github-identity-verification.md) | 提交、推送或更换身份前 |
| 文档迁移与维护过程 | [maintenance/2026-11-09-docs-migration.md](maintenance/2026-11-09-docs-migration.md) | 审计文档结构时 |
| Notify 库说明 | [source/README.md](../source/README.md) 与 `source/Notify.ahk` 的 JSDoc | 改动通知显示或升级库时 |
| 文档维护绑定 | 本入口第 4 节 + `AGENTS.md` 文档维护节 | 每轮更新文档时 |

例外声明：README 保留面向用户的安装、功能、站位与配置说明，作为用户文档权威；开发状态只在入口维护，版本历史在 `docs/history/`。

## 3. 当前工作包与通过条件

- **任务/设计/验收编号：** 无既有编号体系；使用任务名或日期（`2026-11-09-README-config-sync`）。
- **状态：** 候选未开始（2026-11-09 文档迁移完成后提出），等待用户确认或授权。
- **范围：** 决定 README「配置文件说明」的覆盖范围并落实：保留常用示例时明确完整键位以 INI 为准；若要展开，则补齐 `[Timing]` 键并逐项与 INI 对齐。
- **预期产物：** 更新后的 `README.md`；`docs/maintenance/` 中的简要记录。
- **通过条件：** README 与 `source/autofarm.ini` 无矛盾、无断链；若展开 `[Timing]`，每个键都能在 INI 对应段找到；保留“改完用热键重启任意循环即时生效”的说明（人工确认热加载）。
- **非目标：** 不改宏逻辑、默认时序、热键默认值或发布资产；不新增循环。
- **授权边界：** 本任务卡只是记录，不自动构成执行授权；用户最新的暂停或范围指示优先。

## 4. 每轮开发与收尾协议

- 遵循适用全局 `AGENTS.md` 的开发、验证与收尾流程（DSH 为 §7）；本节只写项目命令、环境和额外约束。
- **文档维护绑定：** 通用文档分层、容量预警、整体复审、退出与未决项规则见全局 `AGENTS.md` §6 与 `doc-governance` 技能；本项目不复制规则正文，只维护本入口、`docs/ENGINEERING_DESIGN.md`、`docs/VALIDATION.md`、`docs/history/`、`docs/evidence/`、`docs/maintenance/`。容量沿用全局默认（入口 8,000 / 设计与验证导航各 4,000 / 主题导航 6,000 LF 字符），不设项目覆盖。
- **项目命令：**
  - `AutoHotkey64.exe source\AutoFarm_v5.ahk`：主宏，需管理员，人工运行。
  - `AutoHotkey64.exe source\Notifytest.ahk`：通知冒烟检查，人工运行。
  - `AutoHotkey64.exe source\Examples.ahk`：Notify 库示例，人工运行。
  - `git ls-remote origin`、`git push --dry-run origin main`：远端身份/权限只读检查。
- **验证边界：** 本仓库没有构建系统、CI 或自动化测试；行为验证只能由人工在 Windows + AutoHotkey v2 上完成。文档轮只做链接、状态、容量等静态检查，不能声明宏行为通过。

## 5. 决定与未决事项

| 项目 | 状态、影响与接续条件 | 详细依据 |
|---|---|---|
| 采用 `docs/DEVELOPMENT.md` 单一入口 + 分层 docs | 决定（2026-11-09）：README 保留用户使用说明，版本历史移入 `docs/history/`，开发状态只在入口维护；后续文档轮不再把状态写进 README。 | [迁移记录](maintenance/2026-11-09-docs-migration.md) |
| 本仓库固定 GitHub 身份 `juliakitty08-pixel <juliakitty08@gmail.com>` | 已验证（2026-11-09）：令牌属于该账号，对仓库有 admin/push 权限；与全局默认 `harrywenjie` 不同，提交与推送必须使用本地配置身份。 | [身份核实证据](evidence/2026-11-09-github-identity-verification.md) |
| `gh` CLI 当前登录 `harrywenjie` | 已知限制：不代表本仓库身份，不用于推送或判断本仓库权限；只读 API 查询可用。 | [身份核实证据](evidence/2026-11-09-github-identity-verification.md) |
| README 配置示例覆盖范围 | OPEN（已缓解）：2026-11-09 已删除放在 `[Keys]` 的 `JadeInterval` 示例，并注明完整键位以 INI 为准；示例仍只列 `HealCooldownMs`，是否展开 `[Timing]` 待用户决定。 | [source/autofarm.ini](../source/autofarm.ini) |
| 宏行为验证 | `NOT_RUN`：2026-11-09 未重新人工验证 v5；任何脚本或 INI 默认值改动必须补人工验证。 | [验证导航](VALIDATION.md) |
| `AutoFarm_v3.ahk`、`AutoFarm_v4.ahk`、`AutoFarm.ahk` 旧快照 | 决定：只作参考，不维护、不作为当前目标；除非用户明确要求。 | [工程设计导航](ENGINEERING_DESIGN.md) |

未决项不因整理关闭；`UNKNOWN`、`FAILED`、`NOT_RUN` 和停止/暂停决定保持原状态。

## 6. 命令与验证边界

| 命令 | 用途 | 边界 |
|---|---|---|
| `AutoHotkey64.exe source\AutoFarm_v5.ahk` | 运行主宏 | 需管理员；游戏内行为只能人工确认 |
| `AutoHotkey64.exe source\Notifytest.ahk` | 通知冒烟 | 人工观察通知显示 |
| `AutoHotkey64.exe source\Examples.ahk` | Notify 示例 | 人工观察 |
| `git ls-remote origin` | 远端可读与 refs 对齐 | 只读；不证明写权限 |
| `git push --dry-run origin main` | 身份与推送前置检查 | 已是最新时不触发服务端写权限校验，需配合 API 权限核实 |
| `gh api repos/juliakitty08-pixel/AutoFarm` | 仓库元数据只读查询 | 使用 `harrywenjie` 的 gh 登录，其 `permissions.push=false` 不代表本仓库推送身份 |
| 用 `.git/local-credentials` 令牌调 `GET /user`、`GET /repos/...` | 核实推送身份与权限 | 只读；禁止回显令牌 |

- **运行环境：** Windows 11、AutoHotkey v2（`AutoHotkey64.exe`）、脚本自身请求管理员权限；无构建步骤。
- **未覆盖：** 游戏客户端版本差异、网络延迟、多人世界刷新时机、不同分辨率/UI 缩放、系统权限策略、Release 资产上传。

## 7. 当前交接与下一任务卡

<a id="current-next"></a>

**当前安全点：** 2026-11-09 文档迁移已完成并静态验证；迁移提交之后的 `main` 头部即为最近交付。宏行为未验证。

**接续最小输入：** 本入口第 1、3、5、7 节；[AGENTS.md](../AGENTS.md)；[source/autofarm.ini](../source/autofarm.ini)；[README.md](../README.md) 的「配置文件说明」。

**下一候选：** `2026-11-09-README-config-sync`（README 配置示例与 INI 对齐）。

**通过条件：** 见第 3 节；至少覆盖段位正确、键存在、指向权威文件与无断链。

**不扩展：** 不改宏逻辑、默认时序、热键默认值；不新增循环；不引入自动化测试。

**授权边界：** 下一任务卡是记录，不自动构成执行授权；最新用户暂停、拒绝和项目授权边界优先。
