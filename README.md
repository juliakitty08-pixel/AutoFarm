# AutoFarm

这是一个基于 AutoHotkey v2 的自动刷毒塔与自动采集脚本。    
[下载最新版本](https://github.com/juliakitty08-pixel/AutoFarm/releases/latest)

程序首次运行需要选“run anyway”, 并授权管理员权限，你们信不过雪姐就不要用了。    
程序运行时F10和F11会被占用，自动功能关闭的时候不影响正常游戏。    
要完全退出程序在windows右下角的系统托盘（system tray）里找女法师的图标，右键选Exit退出就可以了。    

---

## 功能简介

### 自动刷宝
- 热键：`F11` 开启 / 关闭
- 功能：
  - 自动循环释放技能：
    - 飒踏流星（Meteor Flight）
    - 千斤坠（Mighty Drop）
    - 神龙吐火（Dragon's Breath）
  - 自动按冷却时间释放治疗技能（Heal）
  - 启动时立即释放一次治疗技能
- 需要你自己先停好采集马并站到起始位置然后按F11开始。
  
---

### 自动采集
- 热键：`F10` 开启 / 关闭
- 功能：
  - 按指定时间间隔自动按下采集键
  - 可用于自动拾取、采集资源等
- 默认采集键F，默认间隔10秒, 都可到配置里修改。（好像有个坐骑可以采集附近的所有资源？我还没试过）

---

## 配置文件说明

请参照注释自行修改热键    
默认配置文件为：

autofarm.ini
```ini
; AutoFarm config
; 这个配置文件请按你自己的热键来修改

[Keys]
; 飒踏流星 默认空白键
MeteorFlight=Space
; 千斤坠  默认热键q
MightyDrop=q
; 神龙吐火  我的热键是x
DragonsBreath=x
; 这是治疗技能，我用的千时余响所以是~键，这是个特殊键(sc029), 改成别的技能热键可以直接用键盘上的键名比如q  
Heal=sc029

[Timing]
; 治疗间隔， 单位是毫秒ms，1000ms=1秒，千时余响是60秒自动收伞，如果用别的治疗技能可以调整成你的技能冷却
HealCooldownMs=60000

[Gather]
;采集热键，默认f
Key=f
；采集间隔，默认10秒
IntervalMs=10000
```

