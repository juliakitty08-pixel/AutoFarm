# 2026-11-09 文档结构迁移记录

## 范围与边界

- 日期：2026-11-09
- 基线：`main` @ `4e67a36`（2026-04-23），与 `origin/main` 一致，工作区干净
- 触发：仓库缺少统一入口 `docs/DEVELOPMENT.md`；README 同时承担版本状态说明；`AGENTS.md` 未绑定文档分层；用户要求按全局规则更新文档结构
- 范围：新增入口、设计/验证导航、历史、证据与维护记录；改写 `AGENTS.md` 为薄项目规则；README 去掉状态类版本说明并加入开发文档导航；`.gitignore` 增加 `/temp/`
- 非目标：未改 `source/*.ahk`、`source/autofarm.ini` 默认值、发布资产或 `assets/` 图片；未做行为验证；未启动新功能

## 迁移前状态

- 旧入口：无 `docs/` 目录；`README.md` 同时承担安装、功能、配置与版本更新说明
- 并行当前状态：README 顶部 v2–v5 版本更新说明（事实上的变更记录）
- 产品/设计/验证资料：`source/autofarm.ini`（配置权威）、`source/AutoFarm_v5.ahk`（实现）、`source/README.md`（第三方 Notify 说明）
- 未决项：README 配置示例不完整、`JadeInterval` 段位错误；v5 行为无仓库内人工验证记录
- 容量基线：迁移前无可测量的入口/导航文件

## 映射与处置

| 原位置 | 分类 | 处置 | 新位置/说明 |
|---|---|---|---|
| 无 `docs/` | 当前状态 | 新建 | [docs/DEVELOPMENT.md](../DEVELOPMENT.md) 唯一入口 |
| `README.md` 第 11–18 行版本更新（v2–v5） | 历史 | 移出并保留 | [docs/history/release-notes.md](../history/release-notes.md)，补发布标签与日期 |
| `README.md` 功能/热键/站位/配置说明 | 产品/用户文档 | 保留原路径 | 入口第 2 节声明为用户说明权威 |
| `README.md` 配置示例中的 `JadeInterval` 两行 | 重复且有误的配置说明 | 删除该两行，保留指向 INI 的说明 | `source/autofarm.ini` `[Timing]` 为权威；入口第 5 节记 OPEN |
| `AGENTS.md` 项目约定 | 项目稳定约束 | 改写为薄规则 + 文档维护绑定 + GitHub 身份例外 | 同路径 |
| `source/README.md` | 第三方库说明 | 保留原路径 | 设计导航链接 |
| 无设计/验证导航 | 设计/验证 | 新建 | [docs/ENGINEERING_DESIGN.md](../ENGINEERING_DESIGN.md)、[docs/VALIDATION.md](../VALIDATION.md) |
| 无身份核实记录 | 证据 | 新建 | [docs/evidence/2026-11-09-github-identity-verification.md](../evidence/2026-11-09-github-identity-verification.md) |

## 保全与去重

- 原文保全：版本说明先由 Git 历史保留（`README.md` @ `4e67a36`），再迁入 `docs/history/release-notes.md`；发布标签、日期取自 GitHub Releases
- 旧锚点：迁移前 README 无内部锚点引用，无需存根
- 通用规则去重：文档分层、会话与临时目录规则改为引用全局 `AGENTS.md` §6 与技能；项目只保留路径、命令、验证约束和例外
- 未决项去向：入口第 5 节（README 配置示例 OPEN、行为 `NOT_RUN`、旧快照不维护）
- 不可变证据：`assets/` 截图与 GitHub Release 未改动

## 验证

- 链接/锚点：8 个文件内共 55 条相对链接（含 README 图片路径）全部解析到存在的文件或目录；本轮文档不使用 `#fragment` 内链，故无锚点解析项
- 容量（LF 字符，对照全局默认预警）：入口 5,099 < 8,000；设计导航 3,209 < 4,000；验证导航 1,429 < 4,000；`AGENTS.md` 2,791（保持薄）；历史、证据与维护记录不计导航容量
- 阅读走查：从入口第 7 节可直接到达 README 配置节与 `source/autofarm.ini`；从第 5 节可直接到达身份证据、验证导航与迁移记录；均无需遍历轮次总账
- 静态检查：用临时脚本 `temp/doc-migration/check_docs.py`（未入库，任务结束清理）扫描 8 个文件的相对链接与容量，全部通过；`git -c core.whitespace=cr-at-eol diff --check` 通过（README 与 `.gitignore` 为 CRLF，需忽略行尾 CR）
- 产品资格：不新增；未运行任何行为验证，宏行为仍为 `NOT_RUN`

## 后续

- 未完成项：README 配置示例覆盖范围待决定（入口第 3 节任务卡）；v5 人工行为验证未做
- 下次触发：README 配置同步完成后、焦点变化、入口/导航超容量预警或用户要求复审
- 备注：`git push --dry-run` 在已最新时不能证明服务端写权限，已用 GitHub API 补证
