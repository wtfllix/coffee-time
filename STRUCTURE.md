# Coffee Time Structure / Coffee Time 结构

## 中文

### 推荐阅读顺序

1. [`project.godot`](project.godot)：Godot 项目与窗口默认配置。
2. [`scenes/main.tscn`](scenes/main.tscn)：运行入口场景。
3. [`scripts/core/main.gd`](scripts/core/main.gd)：窗口停靠和全局界面装配。
4. [`scripts/cafe/cafe_prototype.gd`](scripts/cafe/cafe_prototype.gd)：色块场景、网格寻路与玩家移动。
5. [`scripts/actors/seat_occupancy.gd`](scripts/actors/seat_occupancy.gd)：顾客占座、玩家占座和最少空座规则。
6. [`scripts/ui/prototype_toolbar.gd`](scripts/ui/prototype_toolbar.gd)：置顶、状态与退出控件。
7. [`scripts/orders/order_controller.gd`](scripts/orders/order_controller.gd)：单杯订单状态机。
8. [`scripts/ui/order_panel.gd`](scripts/ui/order_panel.gd)：饮品选择界面。
9. [`scripts/audio/music_controller.gd`](scripts/audio/music_controller.gd)：频道、音量与播放状态。
10. [`scripts/persistence/local_settings.gd`](scripts/persistence/local_settings.gd)：本地音乐设置读写。
11. [`scripts/ui/music_panel.gd`](scripts/ui/music_panel.gd)：频道、播放与音量控件。

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
│   │   ├── warm_cabin_layout_blockout.gd # DEC-014 功能分区与角色尺度灰盒
│   │   └── warm_cabin_structure_preview.gd # CON-006 结构层重复铺设预览
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
    ├── test_seat_occupancy.gd   # 玩家优先与最少空座测试
    ├── test_music_controller.gd # 音乐状态与本地设置测试
    └── test_music_panel.gd      # 播放器 UI 信号与显示测试
```

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

`main.gd` 读取当前显示器的可用矩形，将窗口调整为全宽、25% 高，并贴到任务栏上方。它创建色块咖啡店和原型工具栏。启动和置顶切换后会输出一条 `[CoffeeTime][Window]` 结构化日志，记录嵌入状态、可用矩形和实际窗口状态，供 Windows 实机诊断。

`cafe_prototype.gd` 将可行走区域离散为 32 像素网格。鼠标点击地面后，脚本计算八方向网格路径，并让占位玩家沿路径移动。CON-003 因视角错误已从运行时撤下，当前恢复程序色块房间与家具；柜台、桌子和两名占位顾客不可通行，六个空座保持可达。正式视觉将依据 DEC-013 的投影、CON-004 的气质和 CON-005 的空间分区重制。

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
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
godot4 --headless --path . --script tests/test_music_controller.gd
godot4 --headless --path . --script tests/test_music_panel.gd
```

第一条检查必需文件、`res://` 文件引用和 GDScript 缩进；第二条才是权威的 Godot 解析检查。

## English

### Recommended reading order

1. [`project.godot`](project.godot): Godot project and default window configuration.
2. [`scenes/main.tscn`](scenes/main.tscn): runtime entry scene.
3. [`scripts/core/main.gd`](scripts/core/main.gd): window docking and top-level assembly.
4. [`scripts/cafe/cafe_prototype.gd`](scripts/cafe/cafe_prototype.gd): blockout scene, grid pathfinding, and player movement.
5. [`scripts/actors/seat_occupancy.gd`](scripts/actors/seat_occupancy.gd): customer occupancy, player claims, and minimum free-seat rules.
6. [`scripts/ui/prototype_toolbar.gd`](scripts/ui/prototype_toolbar.gd): always-on-top, status, and exit controls.
7. [`scripts/orders/order_controller.gd`](scripts/orders/order_controller.gd): single-drink state machine.
8. [`scripts/ui/order_panel.gd`](scripts/ui/order_panel.gd): drink selection UI.
9. [`scripts/audio/music_controller.gd`](scripts/audio/music_controller.gd): channels, volume, and playback state.
10. [`scripts/persistence/local_settings.gd`](scripts/persistence/local_settings.gd): local music-settings storage.
11. [`scripts/ui/music_panel.gd`](scripts/ui/music_panel.gd): channel, playback, and volume controls.

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
├── scripts/
│   ├── core/main.gd
│   ├── art_tests/frontal_oblique_blockout.gd
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
    ├── test_seat_occupancy.gd
    ├── test_music_controller.gd
    └── test_music_panel.gd
```

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

`main.gd` reads the current monitor's usable rectangle, makes the window full-width and 25% high, and docks it above the taskbar. It assembles the blockout café and prototype toolbar. Startup and topmost changes print one structured `[CoffeeTime][Window]` marker with embedded state, usable rectangle, and actual window state for Windows diagnostics.

`cafe_prototype.gd` divides the walkable area into a 32-pixel grid. A floor click produces an eight-direction grid path that the placeholder player follows. Counters, tables, and two placeholder customers are solid, while six green free seats remain reachable. The scene also draws one fixed placeholder barista.

`seat_occupancy.gd` independently tracks customer and player seats. Customer reassignment skips the player's claimed seat and caps customer occupancy so at least two seats remain player-accessible.

`prototype_toolbar.gd` emits always-on-top and quit signals. `main.gd` owns window lifecycle so that the UI stays decoupled.

`order_controller.gd` is a view-independent one-drink state machine. `main.gd` converts spatial interactions into state-machine operations and reflects state changes back into the café and toolbar. Every transition also prints a structured marker prefixed with `[CoffeeTime][OrderLoop]`; one drink shares a `loop_id`, and `event=loop_completed` means the empty cup was dismissed and ordering is available again.

`music_controller.gd` manages three stable channel IDs, linear volume, playback intent, and per-channel `AudioStream` pools. `main.gd` connects it to `music_panel.gd`. No candidate music has been imported; a playback request safely returns `false` when the selected channel has no approved tracks and the toolbar explains why.

`local_settings.gd` uses `ConfigFile` to store channel and volume in `user://settings.cfg`. Playback state is deliberately not persisted, so each session still requires an explicit user action to start music.

`music_panel.gd` initially shows only a bottom-right Music button, which expands the channel, play/stop, volume, and track-availability controls upward. Its transparent root does not intercept café clicks. `main.gd` forwards user actions to the music controller and saves settings immediately after channel or volume changes.

`addons/copy_all_errors/` is an MIT-licensed editor-only plugin that adds a Copy All button to the Debugger Errors panel. It is outside the café runtime call chain; `ASSETS.md` and the plugin-local `README.md` record its source, pinned commit, and license.

### Click-movement call chain

1. The player presses the left mouse button in the café.
2. `cafe_prototype.gd::_gui_input()` receives the position.
3. The position is converted into an A* grid cell.
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
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
godot4 --headless --path . --script tests/test_music_controller.gd
godot4 --headless --path . --script tests/test_music_panel.gd
```

The first command checks required files, `res://` file references, and GDScript indentation. The second is the authoritative Godot parse check.
