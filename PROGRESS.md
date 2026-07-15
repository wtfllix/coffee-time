# Coffee Time Progress / Coffee Time 进度

## 中文

### 当前快照

- 当前阶段：第一轮色块原型的核心游戏交互验证。
- 已完成：策划主体与素材策略已锁定；双语文档、Godot 工程骨架、色块咖啡店、家具避障、八向点击移动和单杯订单状态机已建立。Windows 实机已确认八向移动、8 个座位入座，以及点单、等待、取餐到入座流程正常。
- 进行中：使用 3 秒测试饮用时间和结构化打点日志验证游戏核心循环；最终窗口停靠、尺寸和置顶行为延后处理。
- 下一步：在 Godot 输出面板确认 `drinking_started`、`drinking_completed` 和 `loop_completed` 连续出现；随后加入占位 NPC 与玩家优先规则。
- 阻塞：Windows 实机观察到当前渲染为 1280×720，置顶开关不正常；这些窗口问题已决定延期，不阻塞当前游戏逻辑开发。共享环境无法直接完成桌面窗口视觉检查。
- 测试状态：Godot 4.7 编辑器导入、5 帧运行、订单状态机与 1920×270 自动布局测试通过；Windows 实机人工验证通过八向移动、8 个座位和点单到入座流程，饮用结束后的循环尚待人工确认。
- 已通过检查：`./tests/static_check.sh`；必需文件、`res://` 文件引用和 GDScript 缩进一致。

### 验证命令

```bash
godot4 --version
./tests/static_check.sh
godot4 --path . --editor
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_order_controller.gd
godot4 --headless --path . --script tests/test_cafe_layout.gd
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

## English

### Current snapshot

- Phase: core gameplay interaction validation for the first blockout prototype.
- Completed: planning and asset strategy are locked; bilingual documentation, the Godot skeleton, blockout café, furniture avoidance, eight-direction click movement, and the one-drink state machine are established. Windows testing confirms eight-direction movement, seating at all eight seats, and the order-to-seating flow.
- In progress: validate the core game loop with a three-second test consumption time and structured markers; final window docking, sizing, and always-on-top behavior are deferred.
- Next: confirm that `drinking_started`, `drinking_completed`, and `loop_completed` appear in sequence in the Godot output; then add placeholder NPCs and player-priority rules.
- Blockers: Windows currently renders at 1280×720 and the always-on-top toggle does not work correctly. These window issues are deferred and do not block gameplay work. The shared environment cannot visually inspect desktop-window behavior.
- Test status: Godot 4.7 editor import, a five-frame runtime smoke test, the order state-machine test, and the automated 1920×270 layout test pass. Windows manual testing confirms eight-direction movement, all eight seats, and ordering through seating; the post-drinking loop still needs manual confirmation.
- Passed check: `./tests/static_check.sh`; required files, `res://` references, and GDScript indentation are consistent.

### Verification commands

```bash
godot4 --version
./tests/static_check.sh
godot4 --path . --editor
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_order_controller.gd
godot4 --headless --path . --script tests/test_cafe_layout.gd
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
