# AutoFarm

这是一个基于 AutoHotkey v2 的自动刷毒塔与自动采集脚本，附带独立的 AutoSpace 空格连按工具。

[下载最新版本](https://github.com/juliakitty08-pixel/AutoFarm/releases/latest)

程序首次运行需要选“run anyway”, 并授权管理员权限，你们信不过雪姐就不要用了。    
程序运行时F7,F8,F9和F10会被占用，自动功能关闭的时候不影响其它正常游戏。    
要完全退出程序在windows右下角的系统托盘（system tray）里找~~女法师/乌萨奇~~哈奇喵的图标，右键选Exit退出就可以了。    
修改配置文件autofarm.ini以后，用热键重新启动任意循环，修改会立即生效

版本更新说明见[版本历史](docs/history/release-notes.md)。

---

## 功能简介

### 自动刷独山玉
- 热键 `F7`  开启 / 关闭
- 功能：
  - 自动循环释放技能：
    - 陌刀特殊技
    - 原地闪避 （我发现不带方向的闪避可以回到初始位置，并且有不会退下悬崖的保护机制）
    - 等待大约5分钟
- 我自己是镜潭后面山洞二层的三个刷新点，一晚上1000个不是问题。
- 初始站位有要求，站在二层正中间，面向中间那个玉按F7开始。
- 站位不需要很精确，大概就可以了, 如图所示。

<img src="assets\Screenshot 2026-04-14 215328.jpg" alt="Screenshot" width="600">

---

### 自动刷牛筋
- 热键 `F8`  开启 / 关闭
- 功能：
  - 自动循环释放技能：
    - 飒踏流星（Meteor Flight）
    - 千斤坠（Mighty Drop）
    - 灵虚一指（Touch Of Death）
    - 自动搜尸(2秒后点一次f)
- 我自己是刷绣金所后面那个弓箭手，依然需要修一个塔。
- 跟毒塔一样的的三面墙封顶结构，不需要中间平台放马，因为脚本包括了捡拾。
- 原版毒塔一共是22层，但这个弓箭手站的台子本身有高度，所以17层就够。
- 第一只需要手动打掉，再站在弓箭手原来的位置按F8开始
- 墙贴着弓箭手的脸修，这样千斤坠后人物会自动卡到他身后以便灵虚一指

<img src="assets\2026414181641.jpg" alt="Screenshot" width="600">

<img src="assets\2026414181724.jpg" alt="Screenshot" width="600">

<img src="assets\Screenshot 2026-04-22 235129.jpg" alt="Screenshot" width="600">


---

### 自动刷宝 (毒塔)
- 热键：`F9` 开启 / 关闭
- 功能：
  - 自动循环释放技能：
    - 飒踏流星（Meteor Flight）
    - 千斤坠（Mighty Drop）
    - 神龙吐火（Dragon's Breath）
  - 自动按冷却时间释放治疗技能（Heal）
  - 启动时立即释放一次治疗技能
- 刷的是绣金所，就是所谓的“毒塔”,建造教程youtube上很多
- 需要你自己先停好采集马并站到起始位置然后按F9开始。

---

### 自动采集
- 热键：`F10` 开启 / 关闭
- 功能：
  - 按指定时间间隔自动按下采集键
  - 可用于自动拾取、采集资源等
- 默认采集键f，默认间隔10秒（10000毫秒）, 都可到配置里修改。
- 如果用采集马可以修改ini配置文件里的采集键，间隔最好稍微大于10秒，比如10200（毫秒），因为采集马技能冷却是10秒，稍微提高一点容错。

---

### 连续按空格 (AutoSpace)

- 热键：`F9` 开启 / 关闭
- 功能：
  - 按设定间隔连续按空格键
  - 运行中按 `-` 减少间隔、按 `=` 增加间隔，通知会显示新的间隔
  - 关闭循环时，把当前间隔写回 `autospace.ini`
- 默认每次间隔 200 毫秒，每次调整 10 毫秒，可在 `source/autospace.ini` 修改。
- 运行：`AutoHotkey64.exe source\AutoSpace_v1.ahk`；本机安装目录 `D:\ScoopApps\apps\autohotkey\current`，可执行文件 `D:\ScoopApps\apps\autohotkey\current\v2\AutoHotkey64.exe`。
- AutoSpace 运行中占用 `-` / `=`；`F9` 与 AutoFarm 的刷宝 `F9` 冲突，不要同时运行。如需同时使用，请修改 `autospace.ini` 的 `[Hotkeys] Toggle`。

---

## 配置文件说明

请参照注释自行修改热键    
完整键位、默认值与行内注释以 [source/autofarm.ini](source/autofarm.ini) 为准，下面只列常用示例：

autofarm.ini
```ini
; AutoFarm config
; 这个配置文件请按你自己的热键来修改

[Hotkeys]
; Toggle 采集
ToggleGather=F10
; Toggle 刷毒塔
ToggleFarm=F9
; Toggle 刷牛筋BeefTendon
ToggleBeef=F8
; Toggle 刷独山玉
ToggleJade=F7

[Keys]
; 飒踏流星 默认空白键
MeteorFlight=Space
; 千斤坠  默认热键q
MightyDrop=q
; 神龙吐火  我的热键是x, 请修改一下
DragonsBreath=x
; 这是治疗技能，我用的千时余响所以是~键，这是个特殊键(sc029), 改成别的技能热键可以直接用键盘上的键名比如q  
Heal=sc029
; 灵虚一指,这个只有刷牛筋会用到
TouchOfDeath=f
; 拾取 默认也是f
Loot=f
; 陌刀特殊技, 默认也是~键, 这是用来采集独山玉的
MoSpecial=sc029
; 闪避键，用于人物归位
Dodge=LShift

[Timing]
; 治疗间隔， 单位是毫秒ms，1000ms=1秒，千时余响是60秒自动收伞，如果用别的治疗技能可以调整成你的技能冷却
HealCooldownMs=60000

[Gather]
;采集热键，默认f
Key=f
; 采集间隔，默认10秒
IntervalMs=10000
```

### AutoSpace 配置

AutoSpace 的配置在 `source/autospace.ini`（请保持 UTF-8 编码）：

autospace.ini
```ini
[Hotkeys]
; Toggle 连续按空格
Toggle=F9
; 减少按键间隔
GapDecrease=-
; 增加按键间隔（值就是等号）
GapIncrease==

[Keys]
; 连续按下的按键，默认空格
Key=Space

[Timing]
; 每次按键之间的等待间隔，单位毫秒
KeyPressGap=200
; 每次调整的步进值，单位毫秒
Adjustment=10
; 按键按下时长，单位毫秒
TapMs=60
```

---

## 开发文档

- [统一开发入口](docs/DEVELOPMENT.md)：当前目标、任务卡、决定与未决项
- [仓库规则](AGENTS.md)：项目稳定约束、人工验证与提交规范
- [工程设计导航](docs/ENGINEERING_DESIGN.md)：改什么、读哪里
- [验证导航](docs/VALIDATION.md)：人工验证资格与未覆盖范围
- [版本历史](docs/history/release-notes.md)
- [文档迁移记录](docs/maintenance/2026-11-09-docs-migration.md)
