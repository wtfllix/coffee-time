# Coffee Time Progress / Coffee Time 进度

## 2026-07-19 温暖木屋布局概念锁定

- 用户提供 1280×270 同比例草图并确认功能：左侧入口、左中短柜台、右侧两组靠窗桌和前方四人高凳长桌。
- 点单与取餐位置分开，柜台中部使用咖啡机/杯架分隔；柜台后必须保留可容纳两名店员的连续工作区。旧灰盒的 6 像素柜台后地面不再作为正式尺寸。
- 当前缺省窗景锁定为白天晴朗；正式资产将窗框、玻璃和外景分层，为后续当地天气功能预留替换能力。
- 根据草图生成 CON-005 并经用户确认，保存为 `res://assets/concepts/warm_cabin_layout_concept_v1.png`。其原始尺寸为 1934×813，仅作为构图与拆件参考，不直接裁切成运行时背景。
- 下一步按 CON-005 制作严格适配 1280×270、32×48 像素角色尺度的分层灰盒，再依次拆分墙地结构、短柜台、窗景、桌椅和标志物。本组只新增候选图片与文档，没有修改运行时代码，因此未重复运行 Godot 测试。

## 2026-07-19 温暖木屋垂直切片启动

- 用户确认首张温暖木屋咖啡店概念图符合预期方向。
- 概念图已作为 `Candidate` 参考保存到 `res://assets/concepts/warm_cabin_cafe_concept_v1.png`，不得直接用于正式构建。
- 新增 `ART_DIRECTION.md`，明确暖木结构、琥珀灯光、傍晚冷暖对比、低打扰生活动画和温暖木吉他音乐方向。
- 下一步先制作小范围游戏内“氛围角落”，锁定像素密度、调色板、角色比例和家具可读性，再替换完整色块场景。
- 本组仅新增概念参考与文档，没有修改运行时代码，因此未重复运行 Godot 测试。

## 2026-07-19 温暖木屋环境素材试拆

- 基于已确认的木屋方向生成地板、墙板、窗户、吊灯、圆桌和单椅六件试制素材。
- 使用纯洋红背景生成并完成本地去背，透明版保存在 `res://assets/candidates/warm_cabin/environment_sheet_v1.png`；原始去背源图一并保留，便于检查生成与修改过程。
- 新增隔离预览场景 `res://scenes/art_tests/warm_cabin_asset_preview.tscn`，通过六个 `AtlasTexture` 区域读取同一张 3×2 图集，不影响当前主场景。
- 当前素材仍为 `Candidate`：视觉统一性较好，但像素密度明显高于 32 像素网格的最终需求，地板也尚未验证无缝平铺，因此本轮只验证拆分和透明导入流程。
- Godot 4.7.1 headless 已成功加载预览场景并运行五帧；首次检查因共享环境禁止写入默认 Godot 用户目录而崩溃，改用 `/tmp` 下的临时 `HOME` 与 XDG 目录后退出码为 0、无场景错误。
- Windows 实机发现原 3×2 预览网格需要 512 像素高度，会被项目的 1280×270 桌面窗口裁切；预览已改为六件素材单行排列，目标占用 1200×250 像素，不改变主项目窗口策略。

## 2026-07-19 温暖木屋氛围角落

- 新增 `res://scenes/art_tests/warm_cabin_atmosphere_preview.tscn`，按 1280×270 画布组合墙板、地板、两扇傍晚窗户、两组桌椅和两盏吊灯。
- 使用冷色背景、深色结构边缘和低透明度琥珀光区测试整体冷暖关系，并加入一名程序色块角色作为家具比例尺。
- 该场景只评估总体搭配、密度和角色比例，不包含移动、订单或正式灯光系统，也不会替换 `res://scenes/main.tscn`。
- Godot 4.7.1 headless 已成功加载该场景并运行五帧，退出码为 0、无场景解析错误；整体视觉仍需 Windows 实机确认。

## 2026-07-19 温暖木屋完整背景试制

- 实机反馈确认独立墙板和地板没有共享拼接边界，不能用于判断完整咖啡店布局；停止继续修补该组合方案。
- 重新生成统一透视的完整咖啡店背景，墙壁、墙脚、地板、入口、长柜台、窗户和座位在同一画面中组装；原图裁切并缩放为 1280×270 评估版本。
- 新增 `res://scenes/art_tests/warm_cabin_integrated_preview.tscn`，只显示精确尺寸背景，以验证 Windows 桌面条带中的整体气质。
- 当前图片仍为 `Candidate`，只验证构图与氛围；其中家具不可交互，非整数缩放也不代表最终像素规范。确认整体方向后，应按背景层、碰撞家具层和角色层重制正式资产。
- Godot 4.7.1 首次直接加载时因新 PNG 尚未导入而无法取得 `Texture2D`；执行一次 headless 编辑器导入后，预览场景五帧运行退出码为 0。编辑器导入阶段仍有共享环境无法监听本地端口的诊断信息，运行预览场景本身无错误。

## 2026-07-19 完整背景游戏适配试验

- 用户确认 CON-003 的整体风格符合预期，并同意将其作为概念背景接入现有游戏验证。
- `res://scripts/cafe/cafe_prototype.gd` 现在将完整背景绘制在底层，默认隐藏旧房间与家具色块；玩家、咖啡师、顾客、杯子、目标点、寻路和订单逻辑仍保持独立。
- 柜台碰撞与点单/取餐区域调整到背景柜台约 11%–53% 的水平范围和 68–196 像素的垂直范围；桌椅布局暂沿用既有自适应规则，其位置与背景大致对应。
- 这不是正式素材拆层：背景中的家具仍是不可编辑像素，运行时交互使用独立的逻辑矩形。验证目标是确认视觉与玩法能否共同工作，确认后再制作真正的背景层、家具层与角色遮挡层。
- 共享环境验证通过：Godot 4.7.1 主场景五帧运行退出码为 0；1920×270 布局测试确认六个空座仍可达；座位占用测试确认玩家优先与最少空座规则未回归。Windows 中的视觉对齐、点击柜台、取餐与入座仍需实机确认。

## 2026-07-19 摄像机视角重新锁定

- 用户指出此前完整背景采用侧俯视，与“摄像机正对舞台并向下俯拍”的设计目的冲突；CON-003 标记为 `Rejected` 并从 `cafe_prototype.gd` 撤下，主场景恢复程序色块视觉。
- 经过高位正面俯视、降低机位编辑和低机位重新生成三轮比较，用户确认约 20°–25°俯角的正面轴向版本可作为概念图。
- 新增 DEC-013 与 CON-004：摄像机水平旋转为 0°，后墙和柜台水平展开，纵深沿屏幕上下方向表达；禁止等距菱形、侧向视角和高机位地图式俯视。
- 下一步不再直接把完整概念图接入运行时；先按 CON-004 制作一个严格投影的低分辨率灰盒/像素结构测试，验证 1280×270 裁切、人物比例和碰撞对齐后再制作正式资产。
- 撤下 CON-003 后回归检查通过：Godot 4.7.1 主场景五帧运行、1920×270 六个空座可达、座位占用规则和静态引用/缩进检查均通过。

## 2026-07-19 正面低机位俯视灰盒

- 新增 `res://scenes/art_tests/frontal_oblique_blockout.tscn` 与 `res://scripts/art_tests/frontal_oblique_blockout.gd`，用程序几何实现 1280×270 的 DEC-013 投影测试，不依赖 AI 概念图像素。
- 灰盒初版把后墙/地面交线固定在 104 像素高度，柜台明确拆成 20 像素顶面与 62 像素正面，并用逐渐拉开的横向地板分隔表达约 22.5°低机位俯视纵深。
- 场景包含左侧入口、上方长柜台、右侧两张小桌、下方共享桌和一名约 32×48 像素角色比例尺；所有横向边保持水平，深度线保持垂直，用于排除等距与侧向透视漂移。
- 该灰盒只验证投影、空间占比与资产边界，不实现寻路和订单，也不替换 `res://scenes/main.tscn`。
- Godot 4.7.1 已成功加载灰盒并运行五帧，退出码为 0；静态文件引用、GDScript 缩进和新增文件 diff 检查通过。Windows 视觉比例仍需实机确认。
- Windows 实机确认投影方向、柜台顶面/正面、桌椅纵深和角色比例均可接受，仅墙面高度不足。墙地交线因此从 104 像素下移到 120 像素，入口同步增高，地板纵深线重新分配；其余已确认尺寸保持不变。
- 墙面加高后，实机发现柜台仍使用旧纵坐标并落在墙面区域，视觉上像贴墙或嵌墙。该问题确认是几何层级而非单纯色差：柜台及台上设备整体下移，在 120 像素墙脚之后保留 12 像素吧台内侧地面，再绘制 132–152 像素顶面与 152–214 像素正面。
- 第二次实机反馈认为柜台与墙的分离已明显改善，但柜台略偏下。最终灰盒折中为：墙脚保持 120 像素，内侧地面缩至 6 像素，顶面为 126–146 像素，正面压缩为 146–202 像素；台上设备同步上移，墙面与其他家具比例不变。
- Windows 实机确认最终折中版明显改善，灰盒核心比例由此锁定。下一步停止调整程序色块，按 `ART_DIRECTION.md` 的 1280×270 基准制作墙面、地面、柜台、窗户和灯光的第一块正式风格像素样片。

## 中文

### 当前快照

- 当前阶段：从第一轮色块原型进入单人垂直切片规划与内容制作。
- 已完成：策划主体与素材策略已锁定；双语文档、Godot 工程骨架、色块咖啡店、八向点击移动、单杯订单状态机、一名占位咖啡师和两名固定占位顾客已建立。座位规则保证顾客座位阻挡寻路、玩家不能占用，并至少保留两个玩家可用座位。
- 进行中：以美术、氛围和音乐为首要价值，确定垂直切片的情绪板、色彩光感、代表音乐与细微角色动画；停止继续扩展非必要玩法和后台系统。
- 下一步：先建立氛围规格和 15–30 分钟静置陪伴测试标准，再筛选一套场景/UI、至少一首代表音乐和代表角色视觉；任何外部素材必须先在 `ASSETS.md` 批准后导入。
- 阻塞：尚未确定垂直切片的视觉方向，也没有已批准的代表音乐。Windows 实机观察到的 1280×720 与置顶异常继续延期，不阻塞内容制作；垂直切片后恢复发布级窗口验证。
- 测试状态：Godot 4.7 五帧主场景运行、订单状态机、座位优先规则、1920×270 自动布局、音乐状态与本地设置、播放器折叠菜单 UI 测试通过。Windows 调试器已确认无错误和警告。共享环境 600 帧 headless 基线耗时 4.79 秒、峰值常驻内存约 108.3 MiB、无交换；该结果只用于回归对比，不代表 Windows 图形性能。重启不自动播放待有批准曲目后验证。
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
godot4 --headless --path . --script tests/test_music_controller.gd
godot4 --headless --path . --script tests/test_music_panel.gd
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
- 2026-07-18 Asia/Shanghai：新增独立音乐控制器与 `ConfigFile` 本地设置读写，支持三个稳定频道 ID、0.0–1.0 音量、主动播放语义和无授权曲目时的安全拒绝；无窗口自动化测试通过，尚未接入主场景 UI。
- 2026-07-18 Asia/Shanghai：播放器面板已接入主场景，支持三个频道、播放/停止、音量和无曲目提示；频道与音量立即保存，播放状态不保存。五帧运行与 UI 自动化测试通过，等待 Windows 实机验证。
- 2026-07-18 Asia/Shanghai：Windows 确认频道切换、频道与音量恢复、无曲目提示均正常且无红色错误。根据实机反馈，将常驻播放器条改为右下角按钮展开菜单，减少对咖啡店画面和交互的占用；自动化折叠菜单测试通过。
- 2026-07-18 Asia/Shanghai：Windows 复验确认音乐按钮位置可接受、展开菜单完整、收起后不影响咖啡店交互且无红色错误；菜单与场景重叠暂按原型接受，正式垂直切片计划改用音乐图标和完整播放器 UI。观察到绿色信息提示，待取得原文后判断是否需要处理。
- 2026-07-18 Asia/Shanghai：加入 MIT 许可的 Copy All Errors 1.0.0 编辑器插件，固定上游提交并保留许可证与来源记录；绿色 `[CopyAllErrors]` 输出确认为插件状态信息，不属于游戏错误。
- 2026-07-18 Asia/Shanghai：根据插件复制的调试信息，修复 `cafe_prototype.gd` 与 `main.gd` 共 20 条 `UNSAFE_PROPERTY_ACCESS` / `UNTYPED_DECLARATION` 警告；保留严格警告设置，五帧运行及全部回归测试通过。
- 2026-07-18 Asia/Shanghai：Windows 清空旧消息并重新运行后确认调试器无错误和警告。共享环境完成 600 帧 headless 性能基线：4.79 秒、峰值常驻内存约 108.3 MiB、无交换；播放器与本地设置里程碑收口，恢复最终窗口行为验证。
- 2026-07-19 Asia/Shanghai：用户确认当前窗口要求可暂时降低，优先完成游戏内容。新增 DEC-011，将发布级窗口打磨移至垂直切片之后；当前转入统一视觉、代表角色、代表饮品和氛围体验规划。
- 2026-07-19 Asia/Shanghai：用户重申 Coffee Time 以美术、氛围和音乐为主要价值，而非玩法优先。新增 DEC-012；垂直切片改以静置陪伴感、代表音乐和环境角色动画为第一验收标准，轻互动完整性居后。

## English

### Current snapshot

- Phase: transition from the first blockout prototype into single-player vertical-slice planning and content production.
- Completed: planning and asset strategy are locked; bilingual documentation, the Godot skeleton, blockout café, eight-direction click movement, the one-drink state machine, one placeholder barista, and two fixed placeholder customers are established. Seating rules make customer seats block pathfinding, prevent player claims, and preserve at least two player-accessible seats.
- In progress: treat art, atmosphere, and music as the primary value while defining the vertical slice's mood board, color and light, representative music, and subtle character animation. Stop expanding nonessential mechanics and background systems.
- Next: establish the atmosphere specification and 15–30 minute passive-companionship acceptance test, then select one environment/UI set, at least one representative track, and representative character visuals. External assets require approval in `ASSETS.md` before import.
- Blockers: the vertical slice has no selected visual direction or approved representative music yet. The observed 1280×720 and topmost issues remain deferred and do not block content production; release-grade window validation resumes after the vertical slice.
- Test status: the Godot 4.7 five-frame main-scene run, order state-machine test, seating-priority test, automated 1920×270 layout test, music-state/local-settings test, and collapsible player-UI test pass. The Windows debugger is confirmed free of errors and warnings. A 600-frame shared-environment headless baseline took 4.79 seconds, peaked at about 108.3 MiB resident memory, and used no swap; this is only a regression baseline, not Windows graphics performance. No-auto-play awaits an approved track.
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
godot4 --headless --path . --script tests/test_music_controller.gd
godot4 --headless --path . --script tests/test_music_panel.gd
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
- 2026-07-18 Asia/Shanghai: added an independent music controller and `ConfigFile`-based local settings with three stable channel IDs, 0.0–1.0 volume, explicit playback semantics, and safe rejection when no approved tracks exist. The headless automated test passes; main-scene UI integration remains pending.
- 2026-07-18 Asia/Shanghai: connected the player panel to the main scene with three channels, play/stop, volume, and missing-track feedback. Channel and volume save immediately while playback state does not persist. The five-frame run and UI automation pass; Windows validation remains pending.
- 2026-07-18 Asia/Shanghai: Windows confirmed channel switching, restored channel and volume, and missing-track feedback without red errors. Based on playtest feedback, replaced the persistent player strip with a bottom-right button that expands the menu, reducing visual and interaction obstruction; the automated collapse/expand test passes.
- 2026-07-18 Asia/Shanghai: Windows revalidation confirmed acceptable Music-button placement, complete expanded controls, normal café interaction after collapse, and no red errors. Menu overlap is accepted for the prototype; the vertical slice should use a music icon and a complete player UI. Green informational notices were observed and await exact text before triage.
- 2026-07-18 Asia/Shanghai: added the MIT-licensed Copy All Errors 1.0.0 editor plugin, pinned its upstream commit, and retained its license and source records. Green `[CopyAllErrors]` output is confirmed as plugin status information rather than a game error.
- 2026-07-18 Asia/Shanghai: used the copied debugger output to fix 20 `UNSAFE_PROPERTY_ACCESS` / `UNTYPED_DECLARATION` warnings in `cafe_prototype.gd` and `main.gd`. Strict warning settings remain enabled; the five-frame run and all regression tests pass.
- 2026-07-18 Asia/Shanghai: Windows cleared old messages and confirmed a clean debugger after rerunning. The shared environment established a 600-frame headless baseline of 4.79 seconds, about 108.3 MiB peak resident memory, and no swap. The player/local-settings milestone closes and final window-behavior validation resumes.
- 2026-07-19 Asia/Shanghai: the user lowered the immediate window requirements to prioritize game content. DEC-011 moves release-grade window polish after the vertical slice; work now shifts to cohesive visuals, representative characters, one representative drink, and atmosphere.
- 2026-07-19 Asia/Shanghai: the user reaffirmed that Coffee Time prioritizes art, atmosphere, and music rather than gameplay. DEC-012 updates the vertical slice to evaluate passive companionship, representative music, and ambient character animation before light-interaction completeness.
