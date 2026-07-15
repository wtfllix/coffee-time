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

### 当前目录

```text
coffee-time/
├── AGENTS.md               # 代理与维护规则
├── PLAN.md                 # 产品范围与里程碑
├── PROGRESS.md             # 当前状态、测试与日志
├── STRUCTURE.md            # 本文件：结构与数据流
├── DECISIONS.md            # 决策记录
├── ASSETS.md               # 素材授权台账
├── project.godot           # Godot 项目入口配置
├── scenes/
│   └── main.tscn           # 主场景
├── scripts/
│   ├── core/
│   │   └── main.gd         # 桌面窗口和顶层装配
│   ├── cafe/
│   │   └── cafe_prototype.gd # 色块咖啡店与点击移动
│   ├── actors/
│   │   └── seat_occupancy.gd # 顾客与玩家座位占用规则
│   ├── orders/
│   │   ├── drink_definition.gd # 饮品资源类型
│   │   └── order_controller.gd # 一次一杯状态机
│   └── ui/
│       ├── prototype_toolbar.gd # 原型工具栏
│       └── order_panel.gd       # 点单面板
├── data/
│   └── drinks/             # 咖啡与红茶测试配置
├── assets/
│   ├── music/              # 已批准的本地音乐
│   └── placeholder/        # 原型占位素材
└── tests/                  # 自动化与静态检查
    ├── static_check.sh     # 不依赖 Godot 的引用与缩进检查
    ├── test_order_controller.gd # 单杯状态机测试
    ├── test_cafe_layout.gd      # 1920×270 宽度与座位可达性测试
    └── test_seat_occupancy.gd   # 玩家优先与最少空座测试
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
```

`main.gd` 读取当前显示器的可用矩形，将窗口调整为全宽、25% 高，并贴到任务栏上方。它创建色块咖啡店和原型工具栏。

`cafe_prototype.gd` 将可行走区域离散为 32 像素网格。鼠标点击地面后，脚本计算八方向网格路径，并让占位玩家沿路径移动。柜台、桌子和两名占位顾客不可通行；六个绿色空座保持可达。场景同时程序绘制一名固定咖啡师。

`seat_occupancy.gd` 独立记录顾客与玩家座位。顾客重新分配时跳过玩家已选座位，并限制顾客数量，使玩家始终至少有两个可用座位。

`prototype_toolbar.gd` 发送置顶切换与退出信号。信号由 `main.gd` 接收，因此 UI 不直接管理窗口生命周期。

`order_controller.gd` 是与画面解耦的单杯状态机。`main.gd` 将咖啡店空间交互转为状态机操作，并把状态变化再传给工具栏和场景。每次状态切换还会输出以 `[CoffeeTime][OrderLoop]` 开头的结构化打点日志；同一杯饮品共享 `loop_id`，`event=loop_completed` 表示空杯已清理并恢复为可点单状态。

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
- `scripts/audio/`：频道、曲目与播放状态。
- `scripts/persistence/`：窗口、音量和频道设置。
- `data/tracks/` 与 `data/actors/`：曲目和角色配置资源。

### 当前检查命令

```bash
./tests/static_check.sh
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
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

### Current directory tree

```text
coffee-time/
├── AGENTS.md
├── PLAN.md
├── PROGRESS.md
├── STRUCTURE.md
├── DECISIONS.md
├── ASSETS.md
├── project.godot
├── scenes/main.tscn
├── scripts/
│   ├── core/main.gd
│   ├── cafe/cafe_prototype.gd
│   ├── actors/seat_occupancy.gd
│   ├── orders/
│   │   ├── drink_definition.gd
│   │   └── order_controller.gd
│   └── ui/
│       ├── prototype_toolbar.gd
│       └── order_panel.gd
├── data/drinks/
├── assets/
│   ├── music/
│   └── placeholder/
└── tests/
    ├── static_check.sh
    ├── test_order_controller.gd
    ├── test_cafe_layout.gd
    └── test_seat_occupancy.gd
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
```

`main.gd` reads the current monitor's usable rectangle, makes the window full-width and 25% high, and docks it above the taskbar. It assembles the blockout café and prototype toolbar.

`cafe_prototype.gd` divides the walkable area into a 32-pixel grid. A floor click produces an eight-direction grid path that the placeholder player follows. Counters, tables, and two placeholder customers are solid, while six green free seats remain reachable. The scene also draws one fixed placeholder barista.

`seat_occupancy.gd` independently tracks customer and player seats. Customer reassignment skips the player's claimed seat and caps customer occupancy so at least two seats remain player-accessible.

`prototype_toolbar.gd` emits always-on-top and quit signals. `main.gd` owns window lifecycle so that the UI stays decoupled.

`order_controller.gd` is a view-independent one-drink state machine. `main.gd` converts spatial interactions into state-machine operations and reflects state changes back into the café and toolbar. Every transition also prints a structured marker prefixed with `[CoffeeTime][OrderLoop]`; one drink shares a `loop_id`, and `event=loop_completed` means the empty cup was dismissed and ordering is available again.

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
- `scripts/audio/`: channels, tracks, and playback state.
- `scripts/persistence/`: window, volume, and channel settings.
- `data/tracks/` and `data/actors/`: track and actor resources.

### Current check commands

```bash
./tests/static_check.sh
godot4 --headless --path . --quit
godot4 --headless --path . --script tests/test_cafe_layout.gd
godot4 --headless --path . --script tests/test_seat_occupancy.gd
```

The first command checks required files, `res://` file references, and GDScript indentation. The second is the authoritative Godot parse check.
