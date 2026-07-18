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
| MUS-001 | Candidate | Music | User-provided test track pending | Pending | `res://assets/music/` | License and receipt required before import |
| DEV-001 | Approved | Editor plugin | Copy All Errors 1.0.0 | ShardSpace | `res://addons/copy_all_errors/` | MIT; source: https://github.com/smartmita/godot-copy-all-errors; pinned commit `d8dd5bb29bba68d709435889c9c65c94f6fe7e7a`; editor-only, with the license text retained in the plugin directory |

### Candidate source notes

- Kenney: asset pages are generally CC0, but retain the license included with each resource.
- itch.io: each creator defines their terms; marketplace tags are not a license.
- OpenGameArt: entries use different licenses. Prefer CC0 or clear OGA-BY terms and treat GPL, CC-BY-SA, and DRM restrictions cautiously.
