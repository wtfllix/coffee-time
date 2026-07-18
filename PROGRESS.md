# Coffee Time Progress / Coffee Time 进度

## 中文

### 当前快照

- 当前阶段：第一轮色块原型的播放器接口与本地设置。
- 已完成：策划主体与素材策略已锁定；双语文档、Godot 工程骨架、色块咖啡店、八向点击移动、单杯订单状态机、一名占位咖啡师和两名固定占位顾客已建立。座位规则保证顾客座位阻挡寻路、玩家不能占用，并至少保留两个玩家可用座位。
- 进行中：设计并实现最小音乐播放器接口与本地设置；最终窗口停靠、尺寸和置顶行为延后处理。
- 下一步：建立音乐频道、播放状态与本地设置的最小数据流；测试曲目仍须在 `ASSETS.md` 完成授权批准后才能导入。
- 阻塞：Windows 实机观察到当前渲染为 1280×720，置顶开关不正常；这些窗口问题已决定延期，不阻塞当前游戏逻辑开发。共享环境无法直接完成桌面窗口视觉检查。
- 测试状态：Godot 4.7 编辑器导入、5 帧运行、订单状态机、座位优先规则与 1920×270 自动布局测试通过；布局测试确认两名顾客阻挡其座位、六个空座从入口可达。Windows 已人工验证连续两次完整饮品循环、占位 NPC 正常显示、两名顾客占座不可入座且其余六个空座交互正常。
- 已通过检查：`./tests/static_check.sh`；必需文件、`res://` 文件引用和 GDScript 缩进一致。

### 验证命令

```bash
godot4 --version
./tests/static_check.sh
godot4 --path . --editor
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_order_controller.gd
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
```

预期结果：第一条输出 4.7.x；第二条打开编辑器并导入项目；第三条无解析错误退出。

常见错误：

- `godot4: command not found`：Godot 尚未安装或不在 `PATH`。
- 项目导入后纹理模糊：检查纹理过滤是否关闭，以及项目是否使用最近邻采样。
- Windows 窗口位置异常：先确认系统任务栏位置和缩放比例，再检查可用屏幕矩形。

### 时间日志

- 2026-07-14 Asia/Hong_Kong：完成策划拆分，锁定第一轮原型范围。
- 2026-07-14 Asia/Hong_Kong：确认使用 Godot 4.7 Standard、GDScript、简体中文界面与翻译键。
- 2026-07-14 Asia/Hong_Kong：确认素材库原型策略，正式素材需经过授权台账批准。
- 2026-07-14 Asia/Hong_Kong：开始建立项目文件；发现 Godot 缺失与 `.git` 只读阻塞。
- 2026-07-14 Asia/Hong_Kong：完成窗口、工具栏、色块场景与点击移动的第一批代码；静态仓库检查通过，Godot 运行验证待执行。
- 2026-07-14 Asia/Hong_Kong：Godot 4.7 安装完成；编辑器导入与 5 帧运行通过。加入单杯订单、点单菜单、取餐、入座、测试饮用计时和续杯气泡，状态机自动化测试通过。
- 2026-07-14 Asia/Hong_Kong：收到第一次 Windows 反馈。修复嵌入窗口原生操作报错、宽屏留白、四方向移动和座位不可达；新增 1920×270 自动布局测试，确认 8 个座位全部可达。
- 2026-07-15 Asia/Shanghai：第二次 Windows 实测确认当前渲染为 1280×720；八向移动、8 个座位入座及点单到入座流程正常，置顶开关异常。决定暂缓最终窗口行为，优先完善饮用后循环与游戏内容。
- 2026-07-15 Asia/Shanghai：咖啡和红茶的原型饮用时间统一缩短为 3 秒；订单状态机加入 `[CoffeeTime][OrderLoop]` 打点日志，以 `loop_id` 追踪从点单到清理空杯的完整循环。
- 2026-07-15 Asia/Shanghai：Windows 实机日志确认连续两个订单循环均按六个事件完成；两次饮用计时均约 3 秒，清理空杯后可再次点单。核心单杯循环人工验证完成。
- 2026-07-15 Asia/Shanghai：加入一名固定占位咖啡师、两名固定占位顾客和独立座位占用模块；顾客座位阻挡寻路，玩家座位具有保留优先级，且规则保证至少两个玩家可用座位。新增座位规则测试并更新布局测试，全部 headless 检查通过。
- 2026-07-18 Asia/Shanghai：Windows 实机确认占位 NPC 显示正常，两名顾客占座交互正确，其余六个空座可正常使用；占位 NPC 与玩家优先座位规则验证完成，进入播放器接口与本地设置阶段。

## English

### Current snapshot

- Phase: music-player interfaces and local settings for the first blockout prototype.
- Completed: planning and asset strategy are locked; bilingual documentation, the Godot skeleton, blockout café, eight-direction click movement, the one-drink state machine, one placeholder barista, and two fixed placeholder customers are established. Seating rules make customer seats block pathfinding, prevent player claims, and preserve at least two player-accessible seats.
- In progress: design and implement the minimal music-player interface and local settings; final window docking, sizing, and always-on-top behavior remain deferred.
- Next: establish the minimal data flow for music channels, playback state, and local settings. A test track may only be imported after its license is approved in `ASSETS.md`.
- Blockers: Windows currently renders at 1280×720 and the always-on-top toggle does not work correctly. These window issues are deferred and do not block gameplay work. The shared environment cannot visually inspect desktop-window behavior.
- Test status: Godot 4.7 editor import, a five-frame runtime smoke test, the order state-machine test, the seating-priority test, and the automated 1920×270 layout test pass. The layout test confirms two blocked customer seats and six free seats reachable from the entrance. Windows manual testing completed two consecutive drink loops and confirmed correct placeholder NPC rendering, two unavailable customer seats, and normal interaction with the other six free seats.
- Passed check: `./tests/static_check.sh`; required files, `res://` references, and GDScript indentation are consistent.

### Verification commands

```bash
godot4 --version
./tests/static_check.sh
godot4 --path . --editor
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_order_controller.gd
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
```

Expected: the first command reports 4.7.x, the second imports and opens the project, and the third exits without parse errors.

Common failures:

- `godot4: command not found`: Godot is missing or not on `PATH`.
- Blurry imported textures: verify that texture filtering is disabled and nearest-neighbor sampling is used.
- Incorrect Windows position: confirm taskbar location and display scaling before inspecting the usable screen rectangle.

### Timeline

- 2026-07-14 Asia/Hong_Kong: completed planning breakdown and locked the first prototype scope.
- 2026-07-14 Asia/Hong_Kong: selected Godot 4.7 Standard, GDScript, Simplified Chinese UI, and translation keys.
- 2026-07-14 Asia/Hong_Kong: selected an asset-library prototype strategy with approval required in the asset ledger.
- 2026-07-14 Asia/Hong_Kong: began project setup and discovered missing Godot and read-only `.git` blockers.
- 2026-07-14 Asia/Hong_Kong: completed the first window, toolbar, blockout scene, and click-movement code; repository static checks pass, while Godot runtime validation remains pending.
- 2026-07-14 Asia/Hong_Kong: installed Godot 4.7; editor import and a five-frame runtime test pass. Added one-drink ordering, menu, pickup, seating, shortened drinking timer, and refill bubble; the automated state-machine test passes.
- 2026-07-14 Asia/Hong_Kong: received the first Windows feedback. Fixed embedded-window native-operation errors, unused wide-screen space, four-direction movement, and unreachable seats; added a 1920×270 layout test confirming all eight seats are reachable.
- 2026-07-15 Asia/Shanghai: the second Windows test observed 1280×720 rendering; eight-direction movement, all eight seats, and ordering through seating work, while the always-on-top toggle does not. Final window behavior is deferred so work can focus on the post-drinking loop and gameplay content.
- 2026-07-15 Asia/Shanghai: coffee and tea now use a three-second prototype consumption time. The order state machine prints `[CoffeeTime][OrderLoop]` markers with a shared `loop_id` from ordering through empty-cup cleanup.
- 2026-07-15 Asia/Shanghai: Windows logs confirmed two consecutive six-event order loops. Both consumption timers lasted about three seconds, and another order succeeded after empty-cup cleanup. Manual validation of the core one-drink loop is complete.
- 2026-07-15 Asia/Shanghai: added one fixed placeholder barista, two fixed placeholder customers, and an independent seat-occupancy module. Customer seats block pathfinding, player claims are preserved during reassignment, and at least two seats remain player-accessible. The new seating test and updated layout test pass with all headless checks.
- 2026-07-18 Asia/Shanghai: Windows testing confirmed correct placeholder NPC rendering, correct interaction blocking for the two customer seats, and normal use of the other six free seats. Placeholder NPC and player-priority seating validation is complete; work advances to the music-player interface and local settings.
