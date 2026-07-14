# Coffee Time Plan / Coffee Time 计划

## 中文

### 产品定位

Coffee Time 是一款面向独自工作与学习用户的像素咖啡店桌面陪伴游戏。它首先是一个可以进入并停留的陪伴空间，而不是效率工具、传统经营模拟或纯音乐播放器。

核心感受是“今天不是独自度过”。首版为单人体验，由玩家的像素分身、固定咖啡师与常客 NPC 构成共处感；未来可扩展为 Steam 好友共处一店。

### 已锁定体验

- 窗口横跨屏幕底部，位于任务栏上方，默认置顶且背景不透明。
- 默认高度约为屏幕可用高度的 25%；正式版计划提供约 18%、25%、33% 三档。
- 场景采用 3/4 伪等距、32 像素基础网格、约 2.5 头身角色与八方向动画。
- 玩家从左侧入口进入，点击地面移动；点击交互目标后自动走近并执行动作。
- 左上至中央为长柜台，左侧点单、中央取餐；其余区域为小桌与共享长桌。
- 点单完全可选。单人版同一时间只能有一杯玩家饮品。
- 饮品制作约 15–30 秒，做完后永久保留；角色入座后按饮品配置慢慢喝完。
- 喝完后空杯上持续显示无声续杯图标；点击图标后空杯和提示消失。
- 首版世界动作静默，只保留可关闭的极轻 UI 音。
- 音乐分为安静钢琴、柔和爵士、温暖木吉他三个频道，每个频道计划两首授权曲目。
- 玩家每次启动后主动开始播放；系统记住频道和音量，但从随机曲目开头播放。
- 一名固定咖啡师和八名常客构成正式单人内容；店内维持 3–5 名顾客，始终保留至少两个空座。

### 第一轮原型范围

第一轮使用色块和占位角色，验证以下高风险体验：

1. Windows 底部窗口、任务栏避让、置顶切换和屏幕占用。
2. 咖啡店完整一屏布局与 3/4 伪等距可读性。
3. 点击移动、柜台交互、取餐和入座路径。
4. 一次一杯的点单、制作、取餐、饮用和续杯循环。
5. 一名占位咖啡师、两名占位顾客和玩家优先规则。
6. 最小音乐播放接口和一首已授权测试曲目。

### 第一轮暂不实现

- 正式像素素材、角色定制和八名完整常客。
- 三个完整音乐频道。
- Steam、成就、云存档和好友联机。
- 托盘图标、全局快捷键和自动预留桌面工作区。
- 昼夜、天气、经营经济、任务、好感度或失败状态。

### 里程碑

1. 建立文档、工程配置、窗口原型和色块场景。
2. 实现点击移动与基础情境交互。
3. 实现单杯订单循环与测试饮用计时。
4. 加入占位 NPC、播放器接口、本地设置和性能检查。
5. Windows 实机验证后再购买成套素材。

## English

### Product positioning

Coffee Time is a pixel-art desktop café companion for people who work or study alone. It is primarily a place the player can enter and remain in, not a productivity tool, traditional management simulator, or standalone music player.

Its central promise is, “Today was not spent alone.” The first version is single-player, with the player's pixel avatar, a resident barista, and regular NPC customers creating a sense of shared presence. A later version may allow Steam friends to share one café.

### Locked experience

- The opaque window spans the bottom of the screen above the taskbar and is always on top by default.
- Its default height is about 25% of usable screen height; production plans include roughly 18%, 25%, and 33% presets.
- Visuals use a 3/4 pseudo-isometric view, a 32-pixel base grid, approximately 2.5-head-tall characters, and eight-direction animation.
- The player enters from the left and clicks the floor to move. Clicking an interaction target makes the character approach and act.
- A long counter runs from the upper-left to the center: ordering is on the left, pickup is in the center, and seating fills the remaining area.
- Ordering is optional. The single-player version allows only one active player drink.
- Preparation takes about 15–30 seconds. Finished drinks remain indefinitely, and the seated character consumes a drink over its configured duration.
- An empty cup shows a persistent, silent refill bubble. Clicking it removes both the bubble and cup.
- World actions are silent. Only very light, independently switchable UI sounds remain.
- Music is grouped into quiet piano, soft jazz, and warm acoustic guitar channels, with two licensed tracks planned per channel.
- Playback starts only when the player requests it. Channel and volume persist, while a new session starts from the beginning of a random track.
- Production content plans one resident barista and eight regular customers. Three to five customers remain present while at least two seats stay free.

### First prototype scope

The first prototype uses colored shapes and placeholder actors to validate:

1. Windows bottom docking, taskbar avoidance, always-on-top control, and screen footprint.
2. A complete one-screen café and readable 3/4 pseudo-isometric composition.
3. Click movement and paths to the counter, pickup point, and seats.
4. A one-drink order, preparation, pickup, consumption, and refill loop.
5. One placeholder barista, two placeholder customers, and player-priority rules.
6. A minimal music interface and one licensed test track.

### Out of scope for the first prototype

- Production pixel art, character customization, and all eight regular customers.
- All three complete music channels.
- Steam, achievements, cloud saves, and friend multiplayer.
- Tray integration, global shortcuts, and automatic desktop work-area reservation.
- Day/night cycles, weather, economy, quests, affinity, or failure states.

### Milestones

1. Establish documentation, project configuration, the desktop window, and a blockout scene.
2. Implement click movement and basic contextual interactions.
3. Implement the single-drink loop with shortened test timing.
4. Add placeholder NPCs, music interfaces, local settings, and performance checks.
5. Test on Windows before purchasing cohesive asset packs.
