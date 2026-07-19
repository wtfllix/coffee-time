# Coffee Time Asset Ledger / Coffee Time 素材台账

## 中文

### 状态定义

- `Candidate`：候选，仅可用于评估，不得进入正式构建。
- `Approved`：授权已核验，可按记录的范围使用。
- `Rejected`：不兼容或授权不清，不得使用。
- `Replaced`：曾使用，现已由其他素材取代。

### 导入要求

每个外部素材必须记录：唯一 ID、状态、类型、名称、作者、来源链接、下载日期、许可证原文或文件、购买凭证、允许的使用范围、署名要求、是否修改、项目内路径和备注。

禁止仅凭“免费”“免版税”或市场标签判断商用权限。必须确认允许嵌入商业游戏、修改并随 Steam 构建分发。音乐还要确认直播与录播场景。

### 当前台账

| ID | 状态 | 类型 | 名称 | 作者 | 项目路径 | 授权/备注 |
|---|---|---|---|---|---|---|
| AST-000 | Approved | Prototype | 程序绘制色块 | Coffee Time project | 运行时生成 | 项目原创，不含外部素材 |
| CON-001 | Candidate | AI concept reference | 温暖木屋咖啡店概念图 v1 | Coffee Time project / OpenAI image generation | `res://assets/concepts/warm_cabin_cafe_concept_v1.png` | 生成于 2026-07-19；用于构图、冷暖光和气质评估，不得直接进入正式构建；提示词要求超宽幅像素风桌面咖啡店、左侧入口、左上至中央长柜台、右侧座位、暖木材质、琥珀灯光、傍晚蓝色窗景、安静陪伴氛围；未经后期修改 |
| CON-002 | Candidate | AI sprite trial | 温暖木屋环境六件试制图 | Coffee Time project / OpenAI image generation | `res://assets/candidates/warm_cabin/environment_sheet_v1.png` | 生成于 2026-07-19；包含地板、墙板、窗户、吊灯、圆桌和单椅；以 CON-001 风格为参考，在纯洋红背景生成后使用项目外临时 Pillow 环境去背；仅供 `res://scenes/art_tests/warm_cabin_asset_preview.tscn` 评估，尚未锁定像素尺寸、透视或平铺边界，不得进入正式主场景 |
| CON-003 | Rejected | AI integrated background | 温暖木屋完整咖啡店背景 v1 | Coffee Time project / OpenAI image generation | `res://assets/candidates/warm_cabin/integrated_cafe_background_v1_1280x270.png` | 生成于 2026-07-19；侧俯视构图与 DEC-013 冲突，已从主场景撤下；仅保留生成过程记录，不得作为正式场景或后续投影参考 |
| CON-004 | Candidate | AI concept reference | 温暖木屋正面低机位俯视概念 v1 | Coffee Time project / OpenAI image generation | `res://assets/concepts/warm_cabin_frontal_oblique_concept_v1.png` | 生成于 2026-07-19；用户确认可作为概念图；正面轴向、水平旋转 0°、约 20°–25°俯角，锁定后墙/柜台水平展开与屏幕上下纵深；用于 DEC-013 的视角、构图、材质和光感参考，不得直接进入正式构建；未经后期修改 |
| CON-005 | Candidate | AI layout concept | 温暖木屋主题布局概念 v1 | Coffee Time project / OpenAI image generation | `res://assets/concepts/warm_cabin_layout_concept_v1.png` | 生成于 2026-07-19；用户草图提供权威分区，CON-004 与前序试制图提供视角、材质和像素风参考；用户确认布局效果。包含左侧入口、左中短柜台、分离的点单/取餐位、双店员工作区、右侧两组靠窗桌、四人高凳长桌、壁炉与晴天窗景。原始生成尺寸 1934×813，未经裁切；只用于正式资产拆分和布局参考，不得直接进入构建 |
| MUS-001 | Candidate | Music | 待用户提供的测试曲目 | 待填写 | `res://assets/music/` | 导入前需补齐许可证与凭证 |
| DEV-001 | Approved | Editor plugin | Copy All Errors 1.0.0 | ShardSpace | `res://addons/copy_all_errors/` | MIT；来源：https://github.com/smartmita/godot-copy-all-errors；固定提交 `d8dd5bb29bba68d709435889c9c65c94f6fe7e7a`；仅编辑器使用，许可证原文随插件保留 |

### 候选来源说明

- Kenney：官方素材页通常为 CC0，但仍保存具体资源的许可证文件。
- itch.io：每个作者自行规定授权，市场标签不等于许可证。
- OpenGameArt：不同条目使用不同许可证，优先 CC0 或条款明确的 OGA-BY；谨慎处理 GPL、CC-BY-SA 和 DRM 限制。

## English

### Status definitions

- `Candidate`: evaluation only; not allowed in production builds.
- `Approved`: rights verified for the recorded usage.
- `Rejected`: incompatible or unclear rights; do not use.
- `Replaced`: previously used and now superseded.

### Import requirements

Every external asset records a unique ID, status, type, title, creator, source URL, download date, license text or file, purchase receipt, allowed uses, attribution, modifications, project path, and notes.

“Free,” “royalty-free,” or marketplace tags are not sufficient. Verify permission to embed, modify, and distribute the asset in a commercial Steam game. Music must also cover streaming and recorded video where required.

### Current ledger

| ID | Status | Type | Name | Creator | Project path | License / Notes |
|---|---|---|---|---|---|---|
| AST-000 | Approved | Prototype | Programmatic colored shapes | Coffee Time project | Runtime generated | Original project work; no external asset |
| CON-001 | Candidate | AI concept reference | Warm cabin café concept v1 | Coffee Time project / OpenAI image generation | `res://assets/concepts/warm_cabin_cafe_concept_v1.png` | Generated 2026-07-19 for composition, warm/cool lighting, and mood evaluation only; not allowed directly in production builds; prompt requested an ultrawide pixel-art desktop café with a left entrance, upper-left-to-center counter, right seating, warm wood, amber lighting, blue dusk windows, and quiet companionship; no post-processing |
| CON-002 | Candidate | AI sprite trial | Warm cabin six-piece environment trial | Coffee Time project / OpenAI image generation | `res://assets/candidates/warm_cabin/environment_sheet_v1.png` | Generated 2026-07-19 with CON-001 as a style reference; includes floor, wall, window, pendant lamp, round table, and chair; generated on solid magenta and keyed with Pillow in a temporary external environment; evaluation-only in `res://scenes/art_tests/warm_cabin_asset_preview.tscn`; pixel dimensions, perspective, and tiling boundaries are not approved for the production scene |
| CON-003 | Rejected | AI integrated background | Warm cabin integrated café background v1 | Coffee Time project / OpenAI image generation | `res://assets/candidates/warm_cabin/integrated_cafe_background_v1_1280x270.png` | Generated 2026-07-19; its side-oblique composition conflicts with DEC-013 and has been removed from the main scene; retained only as a process record and prohibited as a production or projection reference |
| CON-004 | Candidate | AI concept reference | Warm cabin frontal low-elevation oblique concept v1 | Coffee Time project / OpenAI image generation | `res://assets/concepts/warm_cabin_frontal_oblique_concept_v1.png` | Generated 2026-07-19 and accepted by the user as a concept reference; centered frontal axis, zero horizontal yaw, approximately 20°–25° downward pitch, horizontal back wall/counter, and screen-vertical depth; reference for DEC-013 camera, composition, materials, and light only; not allowed directly in production builds; no post-processing |
| CON-005 | Candidate | AI layout concept | Warm cabin theme layout concept v1 | Coffee Time project / OpenAI image generation | `res://assets/concepts/warm_cabin_layout_concept_v1.png` | Generated 2026-07-19 from the user's authoritative zoning sketch, with CON-004 and the preceding style trial as camera, material, and pixel-style references; layout accepted by the user. It contains a left entrance, short left-center counter, separate order/pickup positions, a two-barista work zone, two right-side window tables, a four-stool communal table, fireplace, and fair-day window inserts. Original 1934×813 output is uncropped and is reference-only for production asset separation and layout; prohibited from direct build use |
| MUS-001 | Candidate | Music | User-provided test track pending | Pending | `res://assets/music/` | License and receipt required before import |
| DEV-001 | Approved | Editor plugin | Copy All Errors 1.0.0 | ShardSpace | `res://addons/copy_all_errors/` | MIT; source: https://github.com/smartmita/godot-copy-all-errors; pinned commit `d8dd5bb29bba68d709435889c9c65c94f6fe7e7a`; editor-only, with the license text retained in the plugin directory |

### Candidate source notes

- Kenney: asset pages are generally CC0, but retain the license included with each resource.
- itch.io: each creator defines their terms; marketplace tags are not a license.
- OpenGameArt: entries use different licenses. Prefer CC0 or clear OGA-BY terms and treat GPL, CC-BY-SA, and DRM restrictions cautiously.
