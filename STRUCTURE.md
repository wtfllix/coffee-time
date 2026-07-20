# Coffee Time Structure / Coffee Time 结构

## 中文

### 推荐阅读顺序

1. [`project.godot`](project.godot)：Godot 项目与窗口默认配置。
2. [`scenes/main.tscn`](scenes/main.tscn)：运行入口场景。
3. [`scripts/core/main.gd`](scripts/core/main.gd)：窗口停靠和全局界面装配。
4. [`scripts/art_tests/isometric_interior_blockout.gd`](scripts/art_tests/isometric_interior_blockout.gd)：当前紧凑等距可玩灰盒、逆投影与逻辑网格寻路。
5. [`scripts/cafe/cafe_prototype.gd`](scripts/cafe/cafe_prototype.gd)：旧长条色块场景、网格寻路与玩家移动，作为回退参考。
6. [`scripts/actors/seat_occupancy.gd`](scripts/actors/seat_occupancy.gd)：顾客占座、玩家占座和最少空座规则。
7. [`scripts/ui/prototype_toolbar.gd`](scripts/ui/prototype_toolbar.gd)：置顶、状态与退出控件。
8. [`scripts/orders/order_controller.gd`](scripts/orders/order_controller.gd)：单杯订单状态机。
9. [`scripts/ui/order_panel.gd`](scripts/ui/order_panel.gd)：饮品选择界面。
10. [`scripts/audio/music_controller.gd`](scripts/audio/music_controller.gd)：频道、音量与播放状态。
11. [`scripts/persistence/local_settings.gd`](scripts/persistence/local_settings.gd)：本地音乐设置读写。
12. [`scripts/ui/music_panel.gd`](scripts/ui/music_panel.gd)：频道、播放与音量控件。

### 当前目录

```text
coffee-time/
├── AGENTS.md               # 代理与维护规则
├── PLAN.md                 # 产品范围与里程碑
├── PROGRESS.md             # 当前状态、测试与日志
├── STRUCTURE.md            # 本文件：结构与数据流
├── DECISIONS.md            # 决策记录
├── ASSETS.md               # 素材授权台账
├── ART_DIRECTION.md        # 当前垂直切片的美术与氛围规范
├── project.godot           # Godot 项目入口配置
├── addons/
│   └── copy_all_errors/    # 编辑器错误/警告复制工具（MIT）
├── scenes/
│   ├── main.tscn           # 主场景
│   └── art_tests/          # Candidate 单件素材与氛围组合的隔离评估场景
├── scripts/
│   ├── core/
│   │   └── main.gd         # 桌面窗口和顶层装配
│   ├── art_tests/
│   │   ├── frontal_oblique_blockout.gd # DEC-013 投影与比例灰盒
│   │   ├── isometric_interior_blockout.gd # 紧凑等距可玩灰盒、逆投影与 A*
│   │   ├── warm_cabin_layout_blockout.gd # DEC-014 功能分区与角色尺度灰盒
│   │   ├── warm_cabin_structure_preview.gd # CON-006 结构层重复铺设预览
│   │   └── warm_cabin_plank_preview.gd # CON-014 概念图约束木板与错缝铺设预览
│   ├── cafe/
│   │   └── cafe_prototype.gd # 色块咖啡店与点击移动
│   ├── actors/
│   │   └── seat_occupancy.gd # 顾客与玩家座位占用规则
│   ├── audio/
│   │   └── music_controller.gd # 音乐频道、音量与播放状态
│   ├── persistence/
│   │   └── local_settings.gd # user:// 本地音乐设置
│   ├── orders/
│   │   ├── drink_definition.gd # 饮品资源类型
│   │   └── order_controller.gd # 一次一杯状态机
│   └── ui/
│       ├── prototype_toolbar.gd # 原型工具栏
│       ├── order_panel.gd       # 点单面板
│       └── music_panel.gd       # 音乐播放器面板
├── tools/
│   └── normalize_warm_cabin_room_shell.gd # CON-023 统一墙地的确定性几何规范化
├── data/
│   └── drinks/             # 咖啡与红茶测试配置
├── assets/
│   ├── candidates/         # 已去背但尚未批准的游戏素材试制品
│   ├── concepts/           # Candidate 概念参考，不进入正式构建
│   ├── music/              # 已批准的本地音乐
│   └── placeholder/        # 原型占位素材
└── tests/                  # 自动化与静态检查
    ├── static_check.sh     # 不依赖 Godot 的引用与缩进检查
    ├── test_order_controller.gd # 单杯状态机测试
    ├── test_cafe_layout.gd      # 1920×270 宽度与座位可达性测试
    ├── test_isometric_layout.gd # 10×10 对称投影、障碍与座位可达性测试
    ├── test_seat_occupancy.gd   # 玩家优先与最少空座测试
    ├── test_music_controller.gd # 音乐状态与本地设置测试
    └── test_music_panel.gd      # 播放器 UI 信号与显示测试
```

当前 `res://scenes/main.tscn` 仍运行旧长条原型，作为订单和 UI 回退参考；`res://scenes/art_tests/isometric_interior_blockout.tscn` 是 DEC-015 的独立可玩迁移场景，尚未接入主入口。

### 当前运行关系

```text
project.godot
  -> scenes/main.tscn
      -> scripts/core/main.gd
          -> scripts/cafe/cafe_prototype.gd
              -> scripts/actors/seat_occupancy.gd
          -> scripts/ui/prototype_toolbar.gd
          -> scripts/ui/order_panel.gd
          -> scripts/orders/order_controller.gd
          -> scripts/ui/music_panel.gd
          -> scripts/audio/music_controller.gd
          -> scripts/persistence/local_settings.gd
```

`project.godot` 以 640×420 像素作为紧凑等距方向的默认渲染与窗口基准。旧 `main.gd` 仍会在 F5 运行时读取当前显示器的可用矩形，将窗口调整为全宽、25% 高，并贴到任务栏上方。这是迁移期的旧主场景回退行为，不会控制 F6 等距场景的渲染比例。启动和置顶切换后会输出一条 `[CoffeeTime][Window]` 结构化日志，记录嵌入状态、可用矩形和实际窗口状态，供 Windows 实机诊断。

`isometric_interior_blockout.gd` 是当前视角迁移目标。它在 10×10 方格坐标中运行八方向 A*，通过严格 2:1 等距公式绘制，并将鼠标屏幕坐标逆投影回逻辑格；当前每格投影为 56×28 像素，地面占 560×280 像素，墙高为 122 像素。柜台、桌子、壁炉、植物和两名顾客阻挡路径，六个空座保持可达。角色与室内物件在同一绘制队列中按 `x + y` 排序，用于保持前后遮挡。独立 F6 场景现在以 1:1 原生画布绘制 DEC-016 已锁定、ASSETS 已批准的 CON-023 结构底图；Godot `Image` 工具分别从 v3 地板源与原始 v2 墙体源采样，并确定性映射到相同的精确四角，墙体最后覆盖地板以保留原生木质墙脚。启用该底图时不绘制程序墙地和重复窗户；黑板、家具、角色与碰撞仍为独立程序层。CON-022 代码仅保留为失败过程回看，开关关闭。素材不决定碰撞，也不进入 F5。当前只接入移动与入座，订单仍在旧主场景中。

`cafe_prototype.gd` 是旧长条回退原型。它继续承载已验证的订单空间交互，直到等距迁移场景通过 Windows 后再逐步移植，不再作为正式视觉方向。

`seat_occupancy.gd` 独立记录顾客与玩家座位。顾客重新分配时跳过玩家已选座位，并限制顾客数量，使玩家始终至少有两个可用座位。

`prototype_toolbar.gd` 发送置顶切换与退出信号。信号由 `main.gd` 接收，因此 UI 不直接管理窗口生命周期。

`order_controller.gd` 是与画面解耦的单杯状态机。`main.gd` 将咖啡店空间交互转为状态机操作，并把状态变化再传给工具栏和场景。每次状态切换还会输出以 `[CoffeeTime][OrderLoop]` 开头的结构化打点日志；同一杯饮品共享 `loop_id`，`event=loop_completed` 表示空杯已清理并恢复为可点单状态。

`music_controller.gd` 管理三个稳定频道 ID、线性音量、播放意图和各频道的 `AudioStream` 曲目池。`main.gd` 将其连接到 `music_panel.gd`；当前没有导入候选音乐，频道没有已批准曲目时，播放请求会安全返回 `false` 并在工具栏显示说明。

`local_settings.gd` 使用 `ConfigFile` 在 `user://settings.cfg` 保存频道与音量。播放状态不会保存，确保每次启动仍由用户主动开始播放。

`music_panel.gd` 默认只显示右下角“音乐”按钮，点击后向上展开频道、播放/停止、音量和曲目可用提示。透明根控件不拦截咖啡店点击；用户操作由 `main.gd` 转给音乐控制器，并在频道或音量变化后立即保存设置。

`addons/copy_all_errors/` 是仅在 Godot 编辑器运行的 MIT 插件，在调试器错误面板加入“复制全部”按钮。它不进入咖啡店运行时调用链；来源、固定提交和许可证记录在 `ASSETS.md` 与插件目录的 `README.md`。

### 点击移动调用链

1. 玩家在咖啡店区域按下鼠标左键。
2. `cafe_prototype.gd::_gui_input()` 接收点击位置。
3. 点击位置被转换为 A* 网格坐标。
4. 不可行走目标被拒绝；合法目标生成路径点列表。
5. `_process()` 逐段移动玩家并更新面向方向。
6. 抵达目标后发出状态文本，工具栏显示结果。

### 点单调用链

1. 玩家点击点单柜台，角色自动走到柜台前。
2. `cafe_prototype.gd` 发出 `interaction_requested(&"order", -1)`。
3. `main.gd` 打开 `order_panel.gd`。
4. 玩家选择 `DrinkDefinition` 资源。
5. `order_controller.gd` 依次进入 `preparing`、`ready`、`carried`、`drinking`、`empty`。
6. 每次状态变化由 `main.gd` 同步到场景杯子图形和工具栏文字。

### 计划中的模块

以下结构尚未实现，不得当作现有代码：

- `scripts/actors/` 中咖啡师、顾客和玩家的动态行为状态机；当前只实现了座位占用规则。
- 窗口设置持久化；当前只实现音乐频道和音量设置。
- `data/tracks/` 与 `data/actors/`：曲目和角色配置资源。

### 当前检查命令

```bash
./tests/static_check.sh
godot4 --headless --path . --script tools/normalize_warm_cabin_room_shell.gd
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_isometric_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
godot4 --headless --path . --script tests/test_music_controller.gd
godot4 --headless --path . --script tests/test_music_panel.gd
```

第一条检查必需文件、`res://` 文件引用和 GDScript 缩进；第二条从已选地板/墙体源图重新生成 CON-023 的 640×420 底图；第三条才是权威的 Godot 解析检查。在 Linux 中若第一条报告 `bash\r`，说明脚本仍是 Windows CRLF 换行，可在临时副本去除行尾 `\r` 后执行，不要为此覆盖用户尚未提交的文件。

## English

### Recommended reading order

1. [`project.godot`](project.godot): Godot project and default window configuration.
2. [`scenes/main.tscn`](scenes/main.tscn): runtime entry scene.
3. [`scripts/core/main.gd`](scripts/core/main.gd): window docking and top-level assembly.
4. [`scripts/art_tests/isometric_interior_blockout.gd`](scripts/art_tests/isometric_interior_blockout.gd): current compact playable isometric migration scene, inverse projection, and logical-grid pathfinding.
5. [`scripts/cafe/cafe_prototype.gd`](scripts/cafe/cafe_prototype.gd): old strip blockout, retained as the order/UI fallback reference.
6. [`scripts/actors/seat_occupancy.gd`](scripts/actors/seat_occupancy.gd): customer occupancy, player claims, and minimum free-seat rules.
7. [`scripts/ui/prototype_toolbar.gd`](scripts/ui/prototype_toolbar.gd): always-on-top, status, and exit controls.
8. [`scripts/orders/order_controller.gd`](scripts/orders/order_controller.gd): single-drink state machine.
9. [`scripts/ui/order_panel.gd`](scripts/ui/order_panel.gd): drink selection UI.
10. [`scripts/audio/music_controller.gd`](scripts/audio/music_controller.gd): channels, volume, and playback state.
11. [`scripts/persistence/local_settings.gd`](scripts/persistence/local_settings.gd): local music-settings storage.
12. [`scripts/ui/music_panel.gd`](scripts/ui/music_panel.gd): channel, playback, and volume controls.

### Current directory tree

```text
coffee-time/
├── AGENTS.md
├── PLAN.md
├── PROGRESS.md
├── STRUCTURE.md
├── DECISIONS.md
├── ASSETS.md
├── ART_DIRECTION.md
├── project.godot
├── addons/copy_all_errors/ # MIT editor utility for copying debugger messages
├── scenes/main.tscn
├── scenes/art_tests/warm_cabin_asset_preview.tscn
├── scenes/art_tests/warm_cabin_atmosphere_preview.tscn
├── scenes/art_tests/warm_cabin_integrated_preview.tscn
├── scenes/art_tests/frontal_oblique_blockout.tscn
├── scenes/art_tests/isometric_interior_blockout.tscn
├── scripts/
│   ├── core/main.gd
│   ├── art_tests/frontal_oblique_blockout.gd
│   ├── art_tests/isometric_interior_blockout.gd
│   ├── cafe/cafe_prototype.gd
│   ├── actors/seat_occupancy.gd
│   ├── audio/music_controller.gd
│   ├── persistence/local_settings.gd
│   ├── orders/
│   │   ├── drink_definition.gd
│   │   └── order_controller.gd
│   └── ui/
│       ├── prototype_toolbar.gd
│       ├── order_panel.gd
│       └── music_panel.gd
├── tools/normalize_warm_cabin_room_shell.gd # deterministic CON-023 geometry normalization
├── data/drinks/
├── assets/
│   ├── candidates/
│   ├── concepts/
│   ├── music/
│   └── placeholder/
└── tests/
    ├── static_check.sh
    ├── test_order_controller.gd
    ├── test_cafe_layout.gd
    ├── test_isometric_layout.gd
    ├── test_seat_occupancy.gd
    ├── test_music_controller.gd
    └── test_music_panel.gd
```

`res://scenes/main.tscn` still runs the old strip prototype as an order/UI fallback. `res://scenes/art_tests/isometric_interior_blockout.tscn` is DEC-015's isolated playable migration scene and is not yet the main entry point.

### Current runtime relationships

```text
project.godot
  -> scenes/main.tscn
      -> scripts/core/main.gd
          -> scripts/cafe/cafe_prototype.gd
              -> scripts/actors/seat_occupancy.gd
          -> scripts/ui/prototype_toolbar.gd
          -> scripts/ui/order_panel.gd
          -> scripts/orders/order_controller.gd
          -> scripts/ui/music_panel.gd
          -> scripts/audio/music_controller.gd
          -> scripts/persistence/local_settings.gd
```

`project.godot` uses 640×420 pixels as the default render and window baseline for the compact isometric direction. The legacy `main.gd` still reads the current monitor's usable rectangle during F5, makes the window full-width and 25% high, and docks it above the taskbar. That is a migration-time fallback for the old main scene and does not control the F6 isometric scene's render aspect. Startup and topmost changes print one structured `[CoffeeTime][Window]` marker with embedded state, usable rectangle, and actual window state for Windows diagnostics.

`isometric_interior_blockout.gd` is the current camera-migration target. It runs eight-direction A* on a logical 10×10 square grid, renders through a strict 2:1 transform, and inverse-projects mouse positions back into grid coordinates. Each cell currently projects to 56×28 pixels, the floor occupies 560×280 pixels, and the walls are 122 pixels high. The counter, tables, fireplace, plants, and two customers are solid while six free seats remain reachable. Actors and interior objects share an `x + y` draw queue for front/back occlusion. The isolated F6 scene now draws the DEC-016-locked, ASSETS-approved CON-023 room shell at native 1:1 canvas scale. A Godot `Image` tool samples the v3 floor source and original v2 wall source separately, then deterministically maps both into the same exact locked corners; walls composite over the floor to retain the native wooden baseboard. With this shell active, procedural walls, floor, and duplicate windows remain disabled while the blackboard, furniture, actors, and collision stay separate. CON-022 code remains only for failed-process inspection with its switch disabled. The art does not define collision and is not used by F5. Movement and sitting are connected; orders remain in the old main scene.

`cafe_prototype.gd` is the old strip fallback. It retains the validated order-space interactions until the isometric migration passes Windows testing and is no longer the production visual direction.

`seat_occupancy.gd` independently tracks customer and player seats. Customer reassignment skips the player's claimed seat and caps customer occupancy so at least two seats remain player-accessible.

`prototype_toolbar.gd` emits always-on-top and quit signals. `main.gd` owns window lifecycle so that the UI stays decoupled.

`order_controller.gd` is a view-independent one-drink state machine. `main.gd` converts spatial interactions into state-machine operations and reflects state changes back into the café and toolbar. Every transition also prints a structured marker prefixed with `[CoffeeTime][OrderLoop]`; one drink shares a `loop_id`, and `event=loop_completed` means the empty cup was dismissed and ordering is available again.

`music_controller.gd` manages three stable channel IDs, linear volume, playback intent, and per-channel `AudioStream` pools. `main.gd` connects it to `music_panel.gd`. No candidate music has been imported; a playback request safely returns `false` when the selected channel has no approved tracks and the toolbar explains why.

`local_settings.gd` uses `ConfigFile` to store channel and volume in `user://settings.cfg`. Playback state is deliberately not persisted, so each session still requires an explicit user action to start music.

`music_panel.gd` initially shows only a bottom-right Music button, which expands the channel, play/stop, volume, and track-availability controls upward. Its transparent root does not intercept café clicks. `main.gd` forwards user actions to the music controller and saves settings immediately after channel or volume changes.

`addons/copy_all_errors/` is an MIT-licensed editor-only plugin that adds a Copy All button to the Debugger Errors panel. It is outside the café runtime call chain; `ASSETS.md` and the plugin-local `README.md` record its source, pinned commit, and license.

### Click-movement call chain

1. The player presses the left mouse button in the café.
2. `isometric_interior_blockout.gd::_gui_input()` receives the position in the migration scene.
3. The screen position is inverse-projected into a logical A* grid cell.
4. Solid destinations are rejected; valid destinations produce a point path.
5. `_process()` moves through path segments and updates facing direction.
6. Arrival publishes status text for the toolbar.

### Ordering call chain

1. The player clicks the order counter and automatically approaches it.
2. `cafe_prototype.gd` emits `interaction_requested(&"order", -1)`.
3. `main.gd` opens `order_panel.gd`.
4. The player selects a `DrinkDefinition` resource.
5. `order_controller.gd` advances through `preparing`, `ready`, `carried`, `drinking`, and `empty`.
6. `main.gd` reflects every state change into the cup visualization and toolbar text.

### Planned modules

These do not exist yet and must not be described as implemented:

- Dynamic player, barista, and customer behavior state machines under `scripts/actors/`; only seat occupancy is implemented now.
- Window-setting persistence; only music channel and volume settings exist now.
- `data/tracks/` and `data/actors/`: track and actor resources.

### Current check commands

```bash
./tests/static_check.sh
godot4 --headless --path . --script tools/normalize_warm_cabin_room_shell.gd
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_isometric_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
godot4 --headless --path . --script tests/test_music_controller.gd
godot4 --headless --path . --script tests/test_music_panel.gd
```

The first command checks required files, `res://` file references, and GDScript indentation. The second regenerates the 640×420 CON-023 shell from the selected floor and wall sources. The third is the authoritative Godot parse check. If the first command reports `bash\r` on Linux, the script still uses Windows CRLF endings; run a temporary LF-normalized copy rather than overwriting uncommitted user files.
