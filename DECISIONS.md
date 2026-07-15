# Coffee Time Decisions / Coffee Time 决策

## 中文

状态使用：`Accepted`（已接受）、`Superseded`（已取代）、`Proposed`（提议中）。

### DEC-001 — 产品首先是桌面陪伴空间

- 日期：2026-07-14
- 状态：Accepted
- 决策：面向独自工作与学习用户，游戏机制服务于“共享安静时光”，不加入效率评分和强制成长。
- 影响：任何新增功能都必须说明它如何增强陪伴感或低打扰体验。

### DEC-002 — 单人核心循环

- 日期：2026-07-14
- 状态：Accepted
- 决策：玩家自由移动，可直接入座，也可完成点单、等待、取餐、入座、饮用与续杯提示。一次只允许一杯玩家订单。
- 影响：首版不实现经济、经验、失败或饮品过期。

### DEC-003 — 底部不透明横条窗口

- 日期：2026-07-14
- 状态：Accepted
- 决策：窗口位于任务栏上方，横跨可用宽度，默认约 25% 高并置顶；允许取消置顶，首版不做托盘或全局快捷键。
- 影响：第一天实机测试屏幕遮挡；若明显影响工作，再新增取代决策。

### DEC-004 — Godot 4.7 Standard 与 GDScript

- 日期：2026-07-14
- 状态：Accepted
- 决策：使用 Godot 4.7 Standard、GDScript 和 Compatibility 渲染器，目标平台为 Windows。
- 影响：共享环境必须提供 `godot` 命令，Windows 设备负责最终桌面行为验证。

### DEC-005 — 像素视觉规范

- 日期：2026-07-14
- 状态：Superseded by DEC-009
- 决策：3/4 伪等距、32 像素网格、约 32×48 像素的 2.5 头身角色、四方向、8–10 FPS。
- 影响：第一次 Windows 试玩后，四方向移动被八方向取代；其他视觉规格保持不变。

### DEC-006 — 素材库原型策略

- 日期：2026-07-14
- 状态：Accepted
- 决策：第一版使用色块或批准的素材库资源；验证体验后再购买成套场景、角色和 UI，并定制关键角色与品牌资产。
- 影响：禁止在技术尺寸确定前大量采购素材。

### DEC-007 — 音乐与静默世界

- 日期：2026-07-14
- 状态：Accepted
- 决策：正式版计划三个氛围频道；世界动作静默，仅保留可关闭的极轻 UI 音。播放由用户每次主动开始。
- 影响：音乐必须有明确商用授权，且播放器和世界行为解耦。

### DEC-008 — 初学者可读性

- 日期：2026-07-14
- 状态：Accepted
- 决策：英文标识符配中文代码注释；`STRUCTURE.md` 集中说明入口、依赖和调用链；运行说明包含命令、预期结果和常见错误。
- 影响：可读性与文档更新属于功能完成标准的一部分。

### DEC-009 — 八方向移动

- 日期：2026-07-14
- 状态：Accepted
- 决策：玩家与 NPC 使用八方向寻路和朝向；只有相邻正交格都可通行时才允许斜向移动，避免切过家具角落。
- 影响：正式角色素材必须包含八方向动画，角色资产量高于原四方向方案。

### DEC-010 — 核心游戏体验优先于最终窗口行为

- 日期：2026-07-15
- 状态：Accepted
- 决策：保留底部桌面窗口作为产品目标，但暂缓处理最终渲染尺寸、停靠与置顶异常；先完成饮品循环、占位 NPC 和玩家优先规则。
- 影响：当前 1280×720 渲染与置顶开关异常被记录为延期问题，不阻塞核心游戏逻辑开发；核心体验稳定后必须恢复 Windows 实机验证。

## English

Statuses: `Accepted`, `Superseded`, and `Proposed`.

### DEC-001 — The product is primarily a desktop companion space

- Date: 2026-07-14
- Status: Accepted
- Decision: serve people working or studying alone; mechanics support quiet shared presence, with no productivity score or mandatory progression.
- Consequence: every feature must explain how it supports companionship or low interruption.

### DEC-002 — Solo core loop

- Date: 2026-07-14
- Status: Accepted
- Decision: the player moves freely, sits without ordering, or orders, waits, collects, sits, drinks, and receives a refill prompt. Only one player drink may be active.
- Consequence: no economy, experience, failure, or drink expiry in the first version.

### DEC-003 — Opaque bottom strip window

- Date: 2026-07-14
- Status: Accepted
- Decision: span the usable width above the taskbar, use about 25% height, and stay on top by default. Always-on-top can be disabled; tray and global shortcuts are deferred.
- Consequence: test obstruction on day one and supersede this decision if it materially harms work.

### DEC-004 — Godot 4.7 Standard with GDScript

- Date: 2026-07-14
- Status: Accepted
- Decision: use Godot 4.7 Standard, GDScript, and the Compatibility renderer for Windows.
- Consequence: the shared environment needs a `godot` command; Windows hardware performs final desktop validation.

### DEC-005 — Pixel visual specification

- Date: 2026-07-14
- Status: Superseded by DEC-009
- Decision: 3/4 pseudo-isometric view, 32-pixel grid, roughly 32×48-pixel 2.5-head-tall characters, four directions, and 8–10 FPS.
- Consequence: the first Windows playtest replaced four-direction movement with eight directions; the other visual specifications remain valid.

### DEC-006 — Asset-library prototype strategy

- Date: 2026-07-14
- Status: Accepted
- Decision: use colored shapes or approved library assets first. Buy cohesive environment, character, and UI packs only after validating the experience, then customize signature characters and brand assets.
- Consequence: do not bulk-purchase assets before technical dimensions are known.

### DEC-007 — Music and a silent world

- Date: 2026-07-14
- Status: Accepted
- Decision: production plans three ambient channels; world actions are silent, with only optional light UI sounds. Playback starts only on user request each session.
- Consequence: every track requires commercial rights, and the player remains decoupled from world behavior.

### DEC-008 — Beginner readability

- Date: 2026-07-14
- Status: Accepted
- Decision: English identifiers with Chinese comments, centralized architecture and call-chain guidance in `STRUCTURE.md`, and run instructions with commands, expected output, and common errors.
- Consequence: readability and documentation updates are part of feature completion.

### DEC-009 — Eight-direction movement

- Date: 2026-07-14
- Status: Accepted
- Decision: player and NPC pathfinding and facing use eight directions. Diagonal movement is allowed only when adjacent orthogonal cells are walkable, preventing corner cutting through furniture.
- Consequence: production character packs must include eight-direction animation, increasing character asset work over the former four-direction approach.

### DEC-010 — Core gameplay before final window behavior

- Date: 2026-07-15
- Status: Accepted
- Decision: retain the bottom desktop window as a product goal, but defer final rendering size, docking, and always-on-top issues while completing the drink loop, placeholder NPCs, and player-priority rules.
- Consequence: the current 1280×720 rendering and broken always-on-top toggle are tracked as deferred issues rather than gameplay blockers; Windows validation must resume after the core experience is stable.
