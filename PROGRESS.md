# Coffee Time Progress / Coffee Time 进度

## 中文

### 当前快照

- 当前阶段：第一轮色块原型启动。
- 已完成：策划主体与素材策略已锁定；双语文档、Godot 工程骨架、底部窗口脚本、色块咖啡店、家具避障和点击移动代码已建立。
- 进行中：Windows 第二轮实机验证。
- 下一步：使用浮动窗口模式复测任务栏停靠、1920 像素宽度利用、八方向移动和 8 个座位点击。
- 阻塞：现有 `.git` 目录只读，无法初始化有效 Git 仓库。共享环境没有图形显示服务，无法在此查看桌面窗口。
- 测试状态：Godot 4.7 编辑器导入、5 帧运行、订单状态机与 1920×270 布局测试通过；Windows 第二轮视觉验证待执行。
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

## English

### Current snapshot

- Phase: first blockout prototype kickoff.
- Completed: planning and asset strategy are locked; bilingual documentation, the Godot skeleton, bottom-window script, blockout café, furniture obstacles, and click-movement code are established.
- In progress: second Windows validation pass.
- Next: retest taskbar docking, 1920-pixel width usage, eight-direction movement, and all eight seat clicks in floating-window mode.
- Blockers: the existing `.git` directory is read-only, preventing repository initialization. The shared environment has no graphical display service, so the desktop window cannot be visually inspected here.
- Test status: Godot 4.7 editor import, a five-frame runtime smoke test, the order state-machine test, and the 1920×270 layout test pass; the second Windows visual pass remains pending.
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
