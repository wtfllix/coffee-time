# Coffee Time

## 中文

Coffee Time 是一款常驻屏幕底部的像素咖啡店桌面陪伴游戏。本仓库当前处于第一轮色块原型阶段。

### 环境要求

- Godot 4.7 Standard（非 .NET 版本）
- Godot 4.7 Export Templates
- Windows 10 或更新版本用于窗口行为验证
- Git（当前共享环境的 `.git` 目录只读，详见 [`PROGRESS.md`](PROGRESS.md)）

### 第一次运行

1. 安装 Godot 4.7 Standard。
2. 在 Godot Project Manager 中点击 **Import**。
3. 选择本目录的 [`project.godot`](project.godot)。
4. 打开项目后按 `F5` 或右上角运行项目按钮。

首次测试桌面停靠前，在 Godot 顶部打开 **Game** 主屏幕，点击右上角下拉菜单并启用 **Make Window Floating on Next Play**。嵌入编辑器内部的预览窗口不能移动、置顶或禁用缩放，这是 Godot 编辑器限制，不是项目错误。

命令行运行：

```bash
godot4 --path . --editor
```

预期结果：屏幕底部、任务栏上方出现一个不透明咖啡店横条。点击可行走地面时，蓝绿色占位角色会绕开柜台和桌子移动。

### 常见问题

- 找不到 `godot4`：确认安装目录已加入系统 `PATH`，或直接通过 Godot Project Manager 导入。
- 点击家具没有移动：这是预期行为；工具栏会提示家具挡住目标。
- 窗口遮挡工作内容：关闭右上角“置顶”，记录实际使用感受，后续再决定是否增加快速隐藏。
- 画面与文档描述不同：先查看 [`PROGRESS.md`](PROGRESS.md) 的测试状态，未运行验证的功能不应视为完成。

### 订单循环日志

测试饮品时，在 Godot 的 **输出** 面板搜索 `[CoffeeTime][OrderLoop]`。同一杯饮品的日志使用相同 `loop_id`，正常顺序为 `order_placed`、`preparation_completed`、`drink_picked_up`、`drinking_started`、`drinking_completed`、`loop_completed`。最后一个事件表示空杯已经清理，可以再次点单。

### 初学者阅读路线

先阅读 [`STRUCTURE.md`](STRUCTURE.md)，再按其中顺序打开三个脚本。代码标识符使用英文，中文注释解释职责、原因、单位和信号流。

## English

Coffee Time is a pixel-art desktop café companion docked to the bottom of the screen. This repository is currently at the first blockout-prototype stage.

### Requirements

- Godot 4.7 Standard (not the .NET build)
- Godot 4.7 Export Templates
- Windows 10 or newer for desktop-window validation
- Git (the shared environment currently exposes a read-only `.git`; see [`PROGRESS.md`](PROGRESS.md))

### First run

1. Install Godot 4.7 Standard.
2. Select **Import** in Godot Project Manager.
3. Choose [`project.godot`](project.godot) in this directory.
4. Open the project and press `F5` or the Run Project button.

Before testing desktop docking, open the **Game** main screen at the top of Godot, open its top-right dropdown, and enable **Make Window Floating on Next Play**. An editor-embedded preview cannot be moved, placed on top, or made unresizable; this is an editor limitation rather than a project error.

Command-line launch:

```bash
godot4 --path . --editor
```

Expected: an opaque café strip appears above the taskbar. Clicking walkable floor moves the teal placeholder player around counters and tables.

### Common issues

- `godot4` is not found: add the installation directory to `PATH`, or import through Godot Project Manager.
- Clicking furniture does not move: expected; the toolbar explains that furniture blocks the destination.
- The window covers work: turn off “Always on top,” record the experience, and revisit quick-hide behavior later.
- Behavior differs from documentation: inspect the test status in [`PROGRESS.md`](PROGRESS.md); unexecuted features are not considered verified.

### Order-loop markers

While testing a drink, search for `[CoffeeTime][OrderLoop]` in Godot's **Output** panel. One drink keeps the same `loop_id`. The expected sequence is `order_placed`, `preparation_completed`, `drink_picked_up`, `drinking_started`, `drinking_completed`, and `loop_completed`. The final event means the empty cup was dismissed and another order can be placed.

### Beginner reading path

Start with [`STRUCTURE.md`](STRUCTURE.md), then open the three scripts in its recommended order. Identifiers are English, while Chinese comments explain responsibilities, rationale, units, and signal flow.
