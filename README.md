# AutoFarm

这是一个基于 AutoHotkey v2 的自动刷毒塔与自动采集脚本。    
[下载最新版本](https://github.com/juliakitty08-pixel/AutoFarm/releases/latest)

程序首次运行需要选“run anyway”, 并授权管理员权限，你们信不过雪姐就不要用了。    
程序运行时F8和F9和F10会被占用，自动功能关闭的时候不影响正常游戏。    
要完全退出程序在windows右下角的系统托盘（system tray）里找女法师的图标，右键选Exit退出就可以了。    
修改配置文件autofarm.ini以后，需重启程序生效（右键exit，再重新打开一次）

v2 增加了配置里可修改热键的功能    
v3 增加了刷牛筋的循环

---

## 功能简介

### 自动刷牛筋
- 热键 `F8`  开启 / 关闭
- 功能：
  - 自动循环释放技能：
    - 飒踏流星（Meteor Flight）
    - 千斤坠（Mighty Drop）
    - 灵虚一指（Touch Of Death）
    - 自动搜尸(2秒后点一次f)
- 我自己是刷绣金所后面那个弓箭手，依然需要修一个塔
- 然后第一只需要手动打掉，再站好位置按开始

---

### 自动刷宝
- 热键：`F9` 开启 / 关闭
- 功能：
  - 自动循环释放技能：
    - 飒踏流星（Meteor Flight）
    - 千斤坠（Mighty Drop）
    - 神龙吐火（Dragon's Breath）
  - 自动按冷却时间释放治疗技能（Heal）
  - 启动时立即释放一次治疗技能
- 刷的是绣金所，就是所谓的“毒塔”
- 需要你自己先停好采集马并站到起始位置然后按F9开始。

---

### 自动采集
- 热键：`F10` 开启 / 关闭
- 功能：
  - 按指定时间间隔自动按下采集键
  - 可用于自动拾取、采集资源等
- 默认采集键f，默认间隔10秒, 都可到配置里修改。（好像有个坐骑可以采集附近的所有资源？我还没试过）

---

## 配置文件说明

请参照注释自行修改热键    
默认配置文件为：

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

[Timing]
; 治疗间隔， 单位是毫秒ms，1000ms=1秒，千时余响是60秒自动收伞，如果用别的治疗技能可以调整成你的技能冷却
HealCooldownMs=60000

[Gather]
;采集热键，默认f
Key=f
; 采集间隔，默认10秒
IntervalMs=10000
```

