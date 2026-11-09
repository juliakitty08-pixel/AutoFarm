# GitHub 身份与推送权限核实

- 日期：2026-11-09（Pacific/Auckland）
- 范围：`E:\AutoFarm` 本地仓库与 `https://github.com/juliakitty08-pixel/AutoFarm`
- 性质：只读核实，不修改仓库，不写远端

## 结论

- 特殊身份仍然有效：本仓库的提交与推送身份为 `juliakitty08-pixel <juliakitty08@gmail.com>`，与全局默认 `harrywenjie <harrywenjie@gmail.com>` 不同。
- `.git/local-credentials` 中的令牌属于 `juliakitty08-pixel`（显示名 LazyRabbit，公开邮箱 `juliakitty08@gmail.com`），对 `juliakitty08-pixel/AutoFarm` 具有 admin / push / pull 权限。
- `gh` CLI 当前登录的是 `harrywenjie`，不是本仓库身份；不能用于推送，也不能用它的 `permissions.push=false` 判断本仓库能否推送。

## 核实方法与结果

| 检查 | 命令/接口 | 结果 |
|---|---|---|
| 本地身份 | `git config --local --list` | `user.name=juliakitty08-pixel`、`user.email=juliakitty08@gmail.com`、`credential.helper=store --file=.git/local-credentials`、`credential.username=juliakitty08-pixel`、`credential.usehttppath=true` |
| 远端 | `git remote -v` | `origin https://github.com/juliakitty08-pixel/AutoFarm`（fetch/push） |
| 远端可读 | `git ls-remote origin` | `HEAD` 与 `refs/heads/main` 均为 `4e67a36`，与本地 `main` 一致 |
| 推送前置 | `git push --dry-run origin main` | `Everything up-to-date`，退出码 0；已是最新时不触发服务端写权限校验，因此补做 API 核实 |
| 令牌归属 | `GET https://api.github.com/user` | `login=juliakitty08-pixel`、`name=LazyRabbit`、`email=juliakitty08@gmail.com` |
| 仓库权限 | `GET https://api.github.com/repos/juliakitty08-pixel/AutoFarm` | `permissions.admin=true`、`push=true`、`pull=true`；`private=false`、`default_branch=main`、`owner=juliakitty08-pixel` |
| gh 登录 | `gh auth status` | `harrywenjie`（keyring），scopes `gist, read:org, repo, workflow`；`Active account: true` |
| 远端提交身份 | `GET /repos/juliakitty08-pixel/AutoFarm/commits/main` | 提交作者 `juliakitty08-pixel`，提交邮箱 `juliakitty08@gmail.com` |

## 凭据处理

- `.git/local-credentials` 含明文令牌，位于 `.git/` 内，不进入 Git；核实过程中只解析、不回显令牌，也不写入文档或日志。
- 提交作者与提交者由本地 `user.name`/`user.email` 决定，已指向该身份；不要改全局配置，也不要为了推送切换全局账号。
- 令牌失效、权限变化或推送失败时，先按网络/认证/权限分类排查，不改用其他账号的凭据。

## 后续触发

- 更换远端、改变推送身份、令牌轮换或出现 403/认证失败时重新核实；本记录只对 2026-11-09 的仓库状态有效。
