# Coffee Time Agent Guide / Coffee Time 代理指南

## 中文

### 项目目标

Coffee Time 是一款面向工作与学习场景的像素咖啡店桌面陪伴游戏。首版使用 Godot 4.7 Standard 与 GDScript，目标平台为 Windows。

核心体验是：玩家进入屏幕底部的咖啡店，用鼠标控制角色移动，可自由入座，也可点单、等待、取餐和饮用。游戏不评价效率，不设置失败或资源压力。

### 开始工作前的阅读顺序

1. `AGENTS.md`：工作规则。
2. `PLAN.md`：产品目标、范围和里程碑。
3. `PROGRESS.md`：真实进度、阻塞与下一步。
4. `STRUCTURE.md`：目录、入口、模块依赖和阅读路线。
5. `DECISIONS.md`：已锁定的重要决策。
6. `ASSETS.md`：素材与音乐授权状态。

### 强制规则

- 使用 Godot 4.7 Standard 和 GDScript；除非 `DECISIONS.md` 新增取代决策，不得擅自更换引擎。
- 变量、函数、类、信号和资源 ID 使用英文；解释性注释使用中文。
- 核心脚本顶部说明职责、输入、输出和依赖。
- 对公开方法、信号和导出参数使用 GDScript `##` 文档注释。
- 注释重点解释原因、状态变化、单位和边界，不逐行复述显而易见的代码。
- 文件引用使用完整 Godot 路径，例如 `res://scripts/cafe/cafe_prototype.gd`。
- 时间参数注明单位为秒；尺寸注明像素或屏幕比例。
- 禁止无说明的魔法数字。可调参数放入常量、导出属性或资源。
- `TODO` 必须包含缺失内容、原因和完成条件。
- 新素材只有在 `ASSETS.md` 标记为 `Approved` 后才能进入正式构建。
- 不得声称未运行的测试已通过。环境缺少工具时，将其记录到 `PROGRESS.md`。
- 修改实现时，在同一变更中更新相关文档。

### 文档归属

- 目标、范围和里程碑只写入 `PLAN.md`。
- 当前完成情况、下一步、测试与阻塞只写入 `PROGRESS.md`。
- 实际目录和运行时关系只写入 `STRUCTURE.md`；计划结构必须明确标注“计划中”。
- 关键取舍写入 `DECISIONS.md`。旧决策不删除，使用“已取代”状态保留历史。
- 素材来源、许可证、凭证、署名和修改记录写入 `ASSETS.md`。

### 更新检查表

- 新增或移动模块：更新 `STRUCTURE.md`。
- 完成里程碑或发现阻塞：更新 `PROGRESS.md`。
- 改变产品或技术方向：更新 `PLAN.md` 和 `DECISIONS.md`。
- 导入、替换或删除素材：更新 `ASSETS.md`。
- 新增运行或测试命令：记录命令、预期结果和常见错误。

## English

### Project mission

Coffee Time is a pixel-art desktop café companion for work and study. The first version uses Godot 4.7 Standard with GDScript and targets Windows.

The player enters a café docked to the bottom of the screen, moves with the mouse, sits freely, or orders, waits for, collects, and drinks a beverage. The application does not score productivity and has no failure or resource pressure.

### Required reading order

1. `AGENTS.md`: working rules.
2. `PLAN.md`: product goals, scope, and milestones.
3. `PROGRESS.md`: actual status, blockers, and next actions.
4. `STRUCTURE.md`: directories, entry points, dependencies, and reading path.
5. `DECISIONS.md`: locked decisions.
6. `ASSETS.md`: art and music licensing status.

### Mandatory rules

- Use Godot 4.7 Standard and GDScript unless a superseding decision is recorded in `DECISIONS.md`.
- Use English identifiers and Chinese explanatory code comments.
- Document each core script's responsibility, inputs, outputs, and dependencies at the top of the file.
- Use GDScript `##` documentation comments for public methods, signals, and exported properties.
- Comments explain rationale, state changes, units, and boundaries instead of translating obvious code line by line.
- Reference files using full Godot paths such as `res://scripts/cafe/cafe_prototype.gd`.
- Express time values in seconds and dimensions in pixels or screen ratios.
- Do not introduce unexplained magic numbers. Put tunable values in constants, exported properties, or resources.
- Every `TODO` must state what is missing, why, and the completion condition.
- Assets may enter production builds only after being marked `Approved` in `ASSETS.md`.
- Never claim an unexecuted test passed. Record missing tooling in `PROGRESS.md`.
- Update relevant documentation in the same change as the implementation.

### Documentation ownership

- Goals, scope, and milestones belong in `PLAN.md`.
- Current status, next actions, tests, and blockers belong in `PROGRESS.md`.
- Actual repository and runtime relationships belong in `STRUCTURE.md`; planned items must be explicitly labelled.
- Important trade-offs belong in `DECISIONS.md`; supersede old decisions rather than deleting them.
- Asset sources, licenses, receipts, attribution, and modifications belong in `ASSETS.md`.

### Update checklist

- Add or move a module: update `STRUCTURE.md`.
- Finish a milestone or find a blocker: update `PROGRESS.md`.
- Change product or technology direction: update `PLAN.md` and `DECISIONS.md`.
- Import, replace, or remove an asset: update `ASSETS.md`.
- Add a run or test command: document the command, expected result, and common failures.
