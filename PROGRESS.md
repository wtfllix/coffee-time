# Coffee Time Progress / Coffee Time 进度

## 2026-07-20 generate2dmap 分层结构试验

- 2026-07-21 最终判定 CON-022 的根因是生成素材不匹配，而非 Godot 缓存或单一绘制顺序错误：墙体和地板来自不同生成源、不同原始几何与不同缩放链，无法形成自然墙地交线。CON-022 标记为 `Rejected` 并从独立 F6 场景撤下；F6 暂时恢复程序结构灰盒，碰撞、家具和交互不变。
- 下一候选 CON-023 改为原生统一结构生成：当前 Windows 截图只锁定 640×420 画布、地板四角 `(320,125)/(600,265)/(320,405)/(40,265)` 与 122 像素墙高；CON-017 只锁定暖木屋材质和现代像素气质。墙体、墙脚和地板必须在同一张空房间结构源图中一次生成，禁止家具、角色、壁炉、植物、黑板、UI 和调试标记。视觉通过后再决定运行时层拆分与接入。
- CON-023 v1 已生成并保存为 `res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-room-shell-source-v1.png`，原图 1548×1016。它成功把墙、原生墙脚和地板统一为同一结构，双窗数量正确且未混入运行物件；但外轮廓仍比锁定灰盒宽，中侧角和前角没有严格落到目标位置。下一次图像迭代只修几何与画布占比，必须保持材质、木板、窗户、光照和空房间内容不变。
- CON-023 v2 源图已保存为 `res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-room-shell-source-v2.png`。生成模型仍把前角做成平切边，因此不再继续随机迭代；新增 `res://tools/normalize_warm_cabin_room_shell.gd`，通过 Godot `Image` API在 2× 目标分辨率分别采样地板、左墙和右墙，再缩回 640×420。输出 `warm_cabin-room-shell-640x420.png` 严格落在锁定的四个地板角和三个墙顶角，墙体最后覆盖地板以保留同源原生墙脚。
- CON-023 已按 1:1 原生画布接入独立 F6 场景；开启时不再绘制程序墙地或重复程序窗户，黑板、家具、角色、深度排序、寻路与碰撞继续独立。清单 `warm-cabin-structure.json` 记录生成源、提示词、规范化工具、精确坐标和运行状态；F5 主场景未改变。
- Godot 4.7.1 已完成三张 CON-023 PNG 导入；规范化工具可重复输出相同 640×420 底图，等距布局/清单/纹理尺寸/座位可达性/壁炉碰撞测试通过，独立 F6 场景无头启动并正常退出，相关文件 `git diff --check` 通过。编辑器导入仍只出现 Copy All Errors 在共享无头环境无法监听本地 TCP 的已知诊断，进程返回 0；最终墙地纹理、程序家具叠放和 Windows 原尺寸观感待实机确认。
- Windows 确认 CON-023 的统一结构和实际叠放效果很好，但不接受当前偏亮、偏橙、窄板且纹理频率较高的地板。开始制作隔离的地板材质 v2：以用户提供的完整咖啡店概念图为地板权威参考，以 CON-023 v2 空房间为编辑目标；只允许把地板改为较深的暖胡桃色、较宽较长木板、较少错缝和克制直纹，墙体、双窗、墙脚、几何和光照必须保持不变。视觉确认前不替换当前 F6 底图。
- Windows 视觉检查确认地板材质 v2 的宽板、深暖色和低纹理密度方向明显改善，并要求只增加一点粗糙生活感。v2 源图已保存为 `res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-floor-style-source-v2.png`；v3 只允许增加少量板间色差、短直木纹、轻微接头变化和柔和磨痕，禁止脏污、裂缝、密集噪点或拟真风化。v2/v3 仍为隔离视觉候选，当前 F6 底图尚未替换。
- Windows 已确认轻微粗糙化地板 v3 可用。v3 保存为 `res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-floor-style-source-v3.png`，规范化工具改为分别读取 v3 地板与原始 v2 墙体，输出 `warm_cabin-room-shell-floor-v3-640x420.png`；这样只替换地板采样，不接受图像编辑对墙体、窗户或墙脚造成的潜在漂移。独立 F6 已切换至该输出，F5、碰撞、家具和交互不变。
- Godot 4.7.1 已成功重新生成并导入 v3 结构底图；`tests/test_isometric_layout.gd` 与独立 F6 五帧启动均返回 0。静态检查内容在去除临时脚本副本的 CRLF 后通过；仓库内 `tests/static_check.sh` 当前仍为 Windows CRLF，Linux 直接执行会把解释器识别为 `bash\r`，本轮未擅自改写该既有文件。编辑器导入只出现 Copy All Errors 无法在共享环境监听本地 TCP 的已知诊断，进程返回 0。
- Windows 最终认可接入后的 CON-023 v3 地板与 v2 墙体组合，DEC-016 将其锁定为首套温暖木屋结构基础，`ASSETS.md` 状态升级为 `Approved`。结构、美术比例与木材方向不再继续随机迭代；下一阶段以该基础制作并接入可独立排序、碰撞和替换的柜台、桌椅、壁炉与装饰素材。F5 迁移仍未开始。
- 首次使用 `$generate2dmap`，锁定 `scene_mode + layered_raster + y_sorted_props + project-native`，目标画布 640×420，美术模式为现代 `pixel_inspired`。现有 10×10 逻辑网格、A* 阻挡和 `x + y` 深度队列继续是玩法几何的事实来源，不从像素推断碰撞。
- 新增 CON-020 `res://assets/candidates/warm_cabin/generate2dmap_v1/`。基础层只包含平坦木地板；墙体作为独立宽结构对象，包含等长后墙、中央角柱和右墙双窗。家具、角色、壁炉、植物、黑板、UI 与调试标记均未烘焙进任何运行候选层。
- 图像生成未能直接遵守目标坐标，因此只保留完整材质内容，并做确定性几何规范化：地板映射到 `(320,82)/(80,202)/(560,202)/(320,322)`；左/右墙分别映射到灰盒四边形，中央角柱单独去背和缩放。带墙参考图改写了基础层，按技能契约判定为失败过程，没有被切出或用作运行图。
- 当前输出包含基础层、墙体层、分层 QA 预览、精确墙体布局指南、三份手写提示词和 `warm_cabin-structure.json`。所有运行候选图尺寸均为 640×420 RGBA。候选尚未接入 Godot，下一步由 Windows 原尺寸检查锯齿、木纹密度、墙地色阶、窗户比例和透明边缘。
- Windows 检查 CON-020 后确认概念图方向和窗户比例基本正确，但墙地外轮廓锯齿明显，地板细缝缩小后呈断续点状。CON-020 标记为 `Replaced`；新增 CON-021 `res://assets/candidates/warm_cabin/generate2dmap_v2/`。
- CON-021 只重做地板内部材质：改用数量更少、视觉更宽、连续且低对比的木板接缝，去除点状、虚线、抖动和微纹理要求。墙体与窗户不重新生成。地板和墙体均在 2560×1680 的 4× 目标坐标中做投影与 alpha 遮罩，再高质量缩回 640×420，使约 1 像素过渡只影响外轮廓。
- CON-021 已按 1:1 原始尺寸接入独立 F6 等距评估场景：基础层和墙体层从设计画布左上角 `(0,0)` 分层绘制，程序墙地保留为透明边缘后备；候选墙体已包含双窗，因此评估时关闭重复的程序窗户，黑板、家具、角色、寻路与碰撞仍由程序层负责。该素材继续保持 `Candidate`，未接入 F5 主场景，等待 Windows 运行画面复查。
- Godot 4.7.1 已完成资源导入；`godot4 --headless --path . --script tests/test_isometric_layout.gd` 通过，独立场景以 `--quit-after 20` 启动并正常退出。导入阶段 Copy All Errors 编辑器插件在无网络套接字的共享无头环境中仍输出 `_sock`/`ERR_CANT_CREATE`，但导入进程返回 0，场景运行与测试没有该错误。
- Windows 首次运行接入版后反馈整体比例与已确认概念图不一致。复核确认严格 2:1 角度本身正确，主要差异是房间只占 480×240 像素，四周留白使程序角色和家具显得偏大。独立场景现进入比例校准：逻辑网格仍为 10×10，单格投影由 48×24 调为 56×28 像素，地面扩大到 560×280，墙高由 76 调为 90 像素，前缘下移并保留约 35 像素底部余量。
- CON-021 本身未被覆盖；当前只围绕原房间中心临时放大 7/6，与新程序几何对齐，供 Windows 判断构图。该缩放可能放大既有纹理瑕疵，不能作为最终资源处理方式；构图确认后再生成原生匹配新坐标的下一版结构层。
- 比例校准后的 Godot 4.7.1 等距布局测试通过，新增断言确认地面宽 560 像素、纵深 280 像素且墙顶和前角都位于 640×420 画布内；独立场景无头启动并正常退出。视觉比例仍需 Windows F6 原尺寸确认。
- Windows 反馈第一次放大后墙体仍偏矮。按概念图中墙高约占地面纵深 40% 的关系，将墙高从 90 提高到 112 像素，并将房间整体下移 10 像素：墙顶约位于 `y=3`，地面前角约位于 `y=395`。CON-021 旧墙图高度不足，校准期间暂时禁用墙体图层并恢复程序墙和程序窗户；木地板候选继续显示。此状态只用于锁定比例，不代表美术回退。
- 墙高校准后的 Godot 4.7.1 测试通过；新增断言确认墙高正好是 280 像素地面纵深的 40%，墙顶和前角仍在画布内。独立场景无头启动并正常退出，等待 Windows F6 视觉确认。
- Windows 继续反馈墙体可略微加高。墙高由 112 增至 122 像素，同时房间再下移 10 像素，使墙顶继续保持约 3 像素余量，地面前角约位于 `y=405`、底部余量约 15 像素。墙高现约为地面纵深的 43.6%，已接近不裁切 640×420 构图的上限。
- 122 像素墙高校准的 Godot 4.7.1 布局测试通过，独立场景无头启动并正常退出；等待 Windows F6 最终确认墙地比例。
- Windows 已确认保持 560×280 地面、122 像素墙高和当前画布占比，比例校准结束。CON-021 因其 640×420 规范化输出仍对应旧 480×240/76 像素几何而标记为 `Replaced`；原始高分辨率创作源图继续保留。
- 新增 CON-022 `res://assets/candidates/warm_cabin/generate2dmap_v3/warm_cabin-structure.json`。本轮选择 `existing_assets`，不再次随机生成：地板直接以四角 UV 从 CON-021 的 1549×1015 高分辨率源图映射到 `(320,125)/(600,265)/(320,405)/(40,265)`；透明墙体源图的非透明区域映射到 `(40,3,560,262)`，自然得到 122 像素墙高和两扇原有窗户。家具、角色、黑板、碰撞和交互没有烘焙进结构层。
- 独立 F6 场景已接入 CON-022，程序墙地仍作为透明边缘后备，程序窗户在候选开启时关闭。Godot 4.7.1 布局测试、清单解析、图层路径检查和场景无头启动通过。共享环境的 dummy renderer 无法读取 viewport 纹理，自动截图返回空纹理并已终止，因此未声称视觉检查通过；下一步由 Windows F6 原尺寸确认采样清晰度、墙脚贴合、窗户位置和黑板叠放。
- Windows 首次检查 CON-022 时发现地板素材未显示。根因是 `draw_colored_polygon()` 的 UV 必须使用 `0.0–1.0` 归一化纹理坐标，接入代码却直接传入了 1549×1015 源图的像素坐标；数值远大于 1 后采样落到纹理边缘，程序地板后备层因此暴露。现保留清单中的可读像素坐标，在绘制前按实际纹理尺寸归一化，并新增四角 UV 数量与范围回归断言。
- UV 修正后的 Godot 4.7.1 布局测试通过，四个地板 UV 均通过 `0.0–1.0` 范围检查；独立场景无头启动并正常退出。共享环境仍无法截图，等待 Windows F6 确认地板纹理已经恢复。
- Windows 截图确认纹理恢复，但地板仍像覆盖在灰盒上的整张图片，没有自然贴合原有等距色块。复核发现单个四边形只由两组三角形插值，而高分辨率源图四角略不对称、不是严格 2:1 平行四边形，因此内部木板线条会产生大范围斜向扭曲。现改为按现有 10×10 逻辑网格绘制 100 个共享顶点的纹理小面，源图 UV 使用双线性插值；房间四角、墙高、家具坐标、碰撞和源素材均不改变。
- 10×10 地板细分后的 Godot 4.7.1 测试通过，覆盖归一化四角、中心双线性插值、清单细分尺寸、座位可达性和壁炉阻挡；独立场景无头启动并正常退出。下一步由 Windows F6 确认木板方向和纹理是否已与原程序色块自然贴合。
- Windows 发现墙体上下存在色块溢出；该现象不是正常素材边缘，而是 CON-022 透明抗锯齿轮廓外露出了后方程序墙面和 4 像素程序描边。候选墙体已经完整包含墙面、墙脚与顶框，因此 CON-022 开启时现完全关闭程序墙体和墙体描边，只保留程序地板作为地板透明边缘后备；关闭候选时仍可恢复完整程序墙地用于逻辑调试。
- 关闭程序墙后，Godot 4.7.1 布局测试与独立场景无头启动通过，未产生新的脚本错误；墙体上下溢边是否完全消失仍需 Windows F6 视觉确认。
- 后续 Windows 标注显示墙脚内侧仍有较大黑色楔形。该区域来自墙体源图自带的深色底边/阴影越过墙脚覆盖在地板上，而不是程序墙残留。结构层顺序已改为“程序地板后备 → 墙体素材 → 10×10 地板表面 → 家具与角色”，让地板在锁定菱形内裁掉墙体向下溢出的像素，同时保留墙面一侧的正常木质踢脚线；几何和素材文件不变。
- 调整结构层顺序后，Godot 4.7.1 布局测试与独立场景无头启动通过；黑色楔形是否完全被地板裁掉仍需 Windows F6 视觉确认。
- Windows 再次截图确认调层后黑带仍存在，证明前一轮将其归因于墙体阴影并不完整。最终定位到地板读取了 `warm_cabin-base-source.png`：该 1549×1015 RGB 创作源图把透明预览棋盘和深色外沿烘焙在像素中，黑带属于地板纹理本身，无法靠绘制顺序去除。CON-022 现改读同目录已完成 alpha 清理的 640×420 RGBA `warm_cabin-base.png`，以其旧几何四角通过现有 10×10 UV 网格映射到锁定的新菱形；墙体仍读取高分辨率透明源图。比例、墙高、家具、碰撞和木板内容不变。
- 切换清理后 RGBA 地板层后，Godot 4.7.1 等距布局测试通过，确认 10×10 纹理细分、座位可达性和完整壁炉碰撞未回归；独立 F6 场景无头启动并正常退出，相关文件 `git diff --check` 通过。共享无头环境不能验证最终画面，黑带是否消失仍以 Windows F6 原尺寸复查为准。
- Windows 复查确认改用 RGBA 地板后黑带仍存在，因此排除单纯的编辑器缓存和 RGB 地板外沿。源图像素检查显示清理后的地板不透明区域没有近黑像素；剩余黑带来自墙体深色墙脚与地板边界分别缩放后的可见接缝。CON-022 在两条墙地交线上新增 7 像素地板纹理重叠带，并从地板内部 0.35 格采样；这是只影响渲染的 bleed，不改变 560×280 地面、122 像素墙高、家具、碰撞或交互。
- Windows 确认 7 像素 bleed 已消除黑缝，但完整露出的地板纹理爬上墙脚，墙地分界显得不自然。现保留 7 像素底层防漏覆盖，只让最底部 1.5 像素可见；其余部分改由暖棕墙脚压边、顶部亮边和底部柔和暗边覆盖，恢复明确的墙地层次且避免纯黑轮廓。
- 墙脚分层修正后，Godot 4.7.1 等距布局测试与独立 F6 场景无头启动通过，清单中的接缝参数与运行常量一致，相关文件 `git diff --check` 通过；最终颜色和墙地层次等待 Windows 原尺寸确认。
- Windows 反馈程序绘制的暖棕墙脚仍像补丁，接缝观感不自然。该人工墙脚现已撤销；结构层改为“程序地板后备 → 10×10 地板表面 → 7 像素隐藏 bleed → 原始墙体与自带木质墙脚”，由墙体素材最后覆盖地板。这样防漏层只存在于墙后，不再作为可见装饰，也不生成与素材纹理不一致的新色带。
- 恢复素材原生墙脚后的 Godot 4.7.1 等距布局测试与独立 F6 场景无头启动通过，清单解析和相关文件 `git diff --check` 通过；墙脚纹理与隐藏 bleed 的最终贴合仍需 Windows 原尺寸确认。

## 2026-07-20 等距结构素材候选 v1

- 正式视觉迁移开始。使用 imagegen 技能的内置图像生成流程，以已确认方向的 CON-017 为唯一风格、投影、材质和像素密度参考，新增 CON-018 `res://assets/candidates/warm_cabin/isometric_structure_v1/`。
- CON-018 是纯洋红背景的 3×2 独立模块图集：2:1 木地板菱形、左/右墙板、左/右墙窗和转角立柱。原图与 imagegen 技能工具生成的透明图均保留；去背检测到 1,160,037/1,572,864 个全透明像素和 7,851 个边缘半透明像素。
- 当前只标记为 `Candidate`，尚未进入可玩场景。已知风险是地板更像整块平台而非最小单格，墙板自带端柱厚度；下一步先评估风格和投影，再决定拆件/缩放或定向重做，不会盲目填充整间咖啡店。
- CON-018 已按 3×2 区域和透明边界拆分为六张 PNG，并作为候选皮肤覆盖到隔离等距灰盒：整块地板覆盖 10×10 逻辑菱形，左墙使用完整面板，右墙重复两块带窗模块，后角叠加立柱。程序墙地仍作无缝底色与逻辑基准，家具、寻路、碰撞和交互未改动。该接入只供 640×420 Windows A/B 检查，不表示素材已批准。
- Windows A/B 截图判定 CON-018 为方案级失败，已标记 `Rejected` 并从灰盒撤下。主要问题：带厚边的整块地板形成“托盘”感；墙板自带端柱，重复后像围栏；左/右原始比例不一，强制拉伸破坏等距关系；木纹密度与对比过高，抢过家具和角色。下一次不再生成通用图集后拉伸组装，而是严格按当前 640×420 灰盒轮廓制作只含墙、地板、窗户和角柱的空房间结构底图；家具与角色继续独立。
- 新增 CON-019 等距空房间结构底图：Windows 灰盒截图只用于锁定摄像机、裁切、方形地面、墙高与双窗位置，CON-017 只用于锁定风格和材质。本版已移除所有家具、角色、植物、壁炉、黑板和调试形状，避免通用模块拉伸。当前仅为 `Candidate`，原图 1549×1015，前缘仍有轻微厚度；未经视觉确认前不裁切、不接入灰盒。
- Windows 原图检查判定 CON-019 的墙顶、地板边缘和窗框阶梯像素过大，锯齿感严重，因此改为 `Rejected` 且不接入灰盒。这不是单纯缩放问题：最近邻缩小会让轮廓更破碎，抗锯齿会让像素风模糊。下一版不再直接要求模型输出伪像素成品；应先获得干净的等距结构设计，再以确定性的低分辨率轮廓和有限调色规则制作实机素材。

## 2026-07-19 可玩等距基础迁移

- 新增并接受 DEC-015：首版垂直切片正式改为 10×10 逻辑正方形、严格正交 2:1 等距投影和 640×420 紧凑桌面角落窗口。DEC-013 与 DEC-014 标记为已取代；DEC-011 的“先垂直切片、后发布级窗口打磨”排期继续有效。
- `res://scripts/art_tests/isometric_interior_blockout.gd` 从静态 A/B 灰盒升级为独立可玩迁移场景。鼠标屏幕坐标通过等距逆投影转换为逻辑格，`AStarGrid2D` 在方格中执行八方向寻路；移动速度为 3.2 格/秒。
- 柜台、两张小桌、共享桌、壁炉、植物和两名顾客座位已设为阻挡。场景暴露八个座位，其中两名顾客占用深色座位，六个绿色座位可点击并自动寻路入座；入座后点击其他地面可起身。底部状态条解释越界、阻挡、寻路和入座结果。
- 新增 `res://tests/test_isometric_layout.gd`，验证 10×10 正方形、两条等距轴等长、左右投影对称、屏幕/网格往返转换、两名顾客阻挡、六个空座从入口可达，以及合法地面点击能产生路径。
- Windows 实机已确认点击移动、家具绕行、6 个空座入座、2 个顾客座位拒绝和起身移动正常。实机同时发现嵌入式 F6 仍由项目旧 1280×270 视口控制；已将 `project.godot` 的默认渲染与窗口基准改为 640×420。当前 `F5` 仍运行旧长条主场景；等距迁移尚未接入点单、取餐、饮用、音乐 UI 或正式逐物件遮挡排序。
- 640×420 实机复查发现窗户和黑板菜单仍沿用地面菱形，比例过大且未贴合墙面投影。两者已改为沿对应墙面等距轴的平行四边形：右墙窗宽约 1.9 格，左墙黑板宽约 1.4 格，并保留独立外框、玻璃与窗棂层次。
- 壁炉底座原已阻挡 A* 的 `(9,1)` 逻辑格，但向上抬高绘制的炉火被鼠标逆投影为后方地面，造成可点击穿透的错觉。现在地面逆投影前会先检查壁炉的可见轮廓；点击炉火或炉身会提示阻挡且不生成移动路径。自动测试已覆盖该轮廓命中。
- 进一步实机检查发现壁炉绘制底座实际跨越 `(8,0)`、`(9,0)`、`(8,1)` 和 `(9,1)` 四格，旧逻辑只阻挡 `(9,1)`，因此角色能从壁炉背面穿入并重合。现已将完整 2×2 占地设为 A* 阻挡，并为四个格子逐一添加回归断言。
- 完整壁炉占地首次测试暴露出右侧靠窗桌的一把空椅与 `(8,1)` 壁炉格重叠。第二张小桌及两把椅子已整体向开放侧移至第 2 行，桌子阻挡格同步由 `(7,1)` 改为 `(7,2)`，保留六个可达空座。
- Windows 截图确认地面上仍显示九个早期通道连通性参考菱形。它们只是半透明调试标记，不属于地板、家具或交互提示；现在 A* 与座位可达性已有自动测试覆盖，因此已删除这组调试绘制。盆栽绿色圆形和炉火橙色圆形仍作为可识别的家具占位保留。
- 截图同时暴露出桌椅仍按“全部桌子、全部椅子”的类型顺序绘制，导致后方椅子也覆盖桌面。座位区现已改为按逻辑纵深 `x + y` 统一排序：后方椅子先绘制，桌子居中，前方椅子后绘制。这是正式等距遮挡的第一步；角色、柜台、壁炉与全部家具的统一深度队列尚未实现。
- 正式素材接入前的统一遮挡队列已实现：柜台、两类桌子、八把椅子、壁炉、两株植物、两名店员、两名顾客和玩家共用 `x + y` 等距纵深排序。相同纵深下家具先绘制、角色后绘制；入口门垫固定在全部世界物件之前的地面层。下一步需要 Windows 实机确认玩家绕行柜台、桌椅和植物时的前后切换是否自然。
- Windows 确认长柜台使用最前角作为单一深度锚点时，整条柜台会在右侧小桌之后绘制并错误覆盖桌子。灰盒阶段已改用柜台占地中心纵深 `5.7` 作为锚点，两名店员仍固定在柜台后层。正式柜台素材需拆分成多个可独立排序的模块，以取代这个灰盒过渡锚点。
- 柜台右侧第一张小桌的左椅原只与柜台相隔约 `0.15` 格，空间不足且纵深刚好落在柜台后层。该桌及两把椅子已整体向右移动 `0.5` 格；逻辑落格与寻路阻挡不变，但柜台与椅子之间现有足够视觉间隔。

## 2026-07-19 正方形等距几何修正

- 用户确认紧凑等距房间应采用逻辑正方形，并在屏幕上投影为左右对称菱形。CON-016 沿用了 11×9 长方形灰盒且生成图混入轻微透视，导致墙长、轴线和前缘不对称，因此标记为 `Replaced`。
- `res://scripts/art_tests/isometric_interior_blockout.gd` 的房间网格由 11×9 调整为严格 10×10；壁炉、右侧植物和入口门垫同步收回新边界。两条等距轴继续使用相同的 24×12 像素半轴，保证正方形投影为对称 2:1 菱形。Godot 4.7.1 五帧运行与静态检查通过。
- 新增 CON-017 `res://assets/concepts/warm_cabin_isometric_interior_concept_v2.png`：以 CON-016 保留室内内容、CON-005 保留暖木屋美术，重新锁定严格正交等距投影。后角居中、两面墙等长、平行边不汇聚，前方两边完全开放。
- CON-017 保留双店员柜台、两张靠窗双人桌、四凳共享桌、壁炉、玩家与两名顾客；当前仍为 `Candidate`，等待 Windows 视觉确认，不代表 DEC-013 已被取代。

## 2026-07-19 紧凑等距室内概念图

- 新增 CON-016 `res://assets/concepts/warm_cabin_isometric_interior_concept_v1.png`：以已确认的 CON-005 为唯一美术风格参考，把 640×420 等距灰盒转换为暖木屋室内微缩概念图。
- 概念图采用固定等距/斜轴测视角、无屋顶和两面剖开结构，室内占绝对主体；不包含街道、外立面、楼层或屋顶设备。布局保留前左入口、左后双店员柜台、分离的点单/取餐设备区、两张靠窗小桌、前右四人共享桌、右后壁炉、植物、玩家与两名顾客。
- 首次生成的共享桌出现五个凳子，不符合灰盒；随后只移除前侧多余中间凳子，最终版本为前后各两个、合计四个座位，其余构图保持不变。
- CON-016 仍为 `Candidate`，只用于与正面长条方案进行氛围、桌面占用和布局方向比较，不代表 DEC-013 已被取代，也不直接进入正式构建。

## 2026-07-19 紧凑等距室内 A/B 灰盒

- 用户提出底部长条虽然高度较低，但横跨屏幕造成较强的主观占用；完整等距建筑示例更紧凑，却因外立面、屋顶和街道占比过高而缺少 Coffee Time 需要的室内陪伴氛围。
- 新增 `res://scenes/art_tests/isometric_interior_blockout.tscn` 与 `res://scripts/art_tests/isometric_interior_blockout.gd`，以 640×420 像素为设计基准，绘制无屋顶、两面剖开的紧凑等距室内。该场景完全隔离，不替换主场景，也暂不取代 DEC-013。
- 灰盒保留入口、分离的点单/取餐位、两名店员工作区、两张靠窗小桌、四人共享桌、壁炉、黑板、植物、玩家和两名顾客比例参考；外围不绘制街道、屋顶或完整建筑外壳，室内是绝对主体。
- 当前只验证窗口占用、室内氛围、功能布局、角色可见性和家具遮挡风险，不接入寻路或订单。灰盒独立运行时会把当前窗口临时设为 640×420 像素，不修改 `project.godot`；Godot 4.7.1 五帧运行与静态资源引用/GDScript 缩进检查通过。共享环境的 dummy renderer 无法使用 Movie Maker 输出截图并触发崩溃，因此未声称自动截图通过；下一步由 Windows 将其与 1280×270 正面灰盒进行 A/B 视觉比较。

## 2026-07-19 回退至 CON-014

- Windows 视觉检查要求撤回 CON-015。共享 12 色调色板与 2×2 像素簇处理没有改善整体观感，因此 CON-015 标记为 `Rejected`，只保留失败过程。
- `res://scripts/art_tests/warm_cabin_plank_preview.gd` 已恢复读取 `res://assets/candidates/warm_cabin/plank_skins_v4/`；CON-014 重新成为当前 `Candidate`。铺设、错缝、木板尺寸与行高均未改动，其他未提交修改未被覆盖。

## 2026-07-19 墙地统一色相与像素簇

- Windows 反馈确认 CON-014 整体方向良好，但墙地像两种不同木材，颜色割裂；同时纹理包含过多近似色与细小像素，像素感不足。CON-014 标记为 `Replaced`，保留为本轮调整前基线。
- 新增 CON-015：以 CON-014 墙地源图、CON-005 概念图和彼此材质为交叉参考，生成同一暖红胡桃色系的墙板与地板。墙面只比地板降低约 12% 明度，不再改变木材色相；地板同时降低原有橙色饱和感。
- 去背与最近邻拆分后，八块木板共同计算一套 12 色中等调色板，再进行 2×2 像素簇化并恢复原尺寸。该处理保留 CON-014 的中等木材层次，但消除大量近似色和平滑过渡，避免 CON-013 四色方案的过度简化。
- `res://scripts/art_tests/warm_cabin_plank_preview.gd` 已改读 `res://assets/candidates/warm_cabin/plank_skins_v5/`；铺设、错缝、尺寸和行高不变。Godot 4.7.1 已完成十二张源图/拆件导入，五帧预览运行通过；静态资源引用与 GDScript 缩进检查通过，共享环境仍只出现编辑器本地 TCP 监听限制。CON-015 仍为隔离候选，下一步由 Windows 检查统一色相是否自然、墙地明度是否仍可区分，以及像素颗粒是否达到预期。

## 2026-07-19 概念图约束木板 v4

- Windows 反馈判定 CON-013 完全不可用：强制四色量化把木材简化成纯色板和少量线条，失去概念图中的材质层次；CON-013 标记为 `Rejected`。
- 新增 CON-014：直接以已确认的 CON-005 布局概念图约束像素气质、墙地明暗和整体材质关系，并以 CON-006 结构图约束木材颗粒与暖色范围；不再使用 `ce3` 或强制调色板量化。
- 地板首次生成时错误地在每个候选框内部绘制多行拼板，未导入项目；随后只修正为四块单一、连续的独立木板。墙板另行生成更暗、更哑光的四块单板。洋红去背后只进行象限拆分与最近邻缩放，墙板为 128/160/192/224×16 像素，地板为 96/128/160/208×20 像素。
- `res://scripts/art_tests/warm_cabin_plank_preview.gd` 已改读 `res://assets/candidates/warm_cabin/plank_skins_v4/`，铺设算法、错缝与行高保持不变。Godot 4.7.1 已完成十二张源图/拆件导入，五帧预览运行通过；静态资源引用与 GDScript 缩进检查通过，共享环境仍只出现编辑器本地 TCP 监听限制。CON-014 仍为隔离候选，下一步由 Windows 视觉检查确认其是否真正接近概念图，而不是再次落入偏拟真或过度简化。

## 2026-07-19 风格化低色阶木板

- Windows 视觉反馈判定 CON-012 的长曲线木纹、细碎色阶和明暗过渡具有拟真感，不符合当前温暖木屋的风格化像素方向；CON-012 标记为 `Rejected`，但逐条木板、错缝和 16–20 像素地板行高逻辑继续保留。
- 新增 CON-013：墙板与地板分别生成四块极简源板，并在去背和拆分后确定性量化到每块最多四种不透明颜色。地板使用蜂蜜棕平面色块，墙板使用更暗的可可胡桃色；内部只保留少量水平短线、阶梯线和矩形像素标记。
- CON-013 明确禁止真实年轮、连续曲线、渐变、噪点、抖色、结疤、三维倒角和完整外框。`res://scripts/art_tests/warm_cabin_plank_preview.gd` 已改读 `res://assets/candidates/warm_cabin/plank_skins_v3/`，铺设算法与尺寸不变。
- 当前仍为隔离预览候选，尚未进入主场景。Godot 4.7.1 已完成八张拆件导入，五帧预览运行通过；静态资源引用与 GDScript 缩进检查通过。共享环境仍只出现编辑器本地 TCP 监听限制；下一步由 Windows 视觉检查确认它是否从“偏拟真”校正到了“风格化但不过分空白”。

## 2026-07-19 墙地木板皮肤 v2

- 用户明确 `exec-d55616f1-b1e8-461b-9ebd-76bf274767f7.png` 是本轮需要重新核对的 `ce3` 木纹参考。复查确认其木色和纹理方向合适，但四周完整深色描边属于单件展示边框，不适合直接连续铺装；缩至 10–16 像素行高后描边与纹理还会被进一步放大和压扁。
- 新增 CON-012：地板保留 `ce3` 的蜂蜜胡桃木色、长木纹和像素密度，取消完整矩形描边，只允许细下缘板缝；墙板单独生成更暗、更哑光、更低对比的横板，避免墙地继续连成同一种表面。
- 洋红源图使用 Pillow 12.3.0 去背并按四个象限拆分。墙板长度为 128/160/192/224 像素、高 16 像素；地板长度为 96/128/160/208 像素、高 20 像素。预览改读 `res://assets/candidates/warm_cabin/plank_skins_v2/`，地板纵深行高由 10–16 像素提高到 16–20 像素，减少纹理压缩。
- CON-012 仍为隔离预览候选，尚未进入主场景。Godot 4.7.1 已导入十二张源图/拆件，临时可写用户目录下的五帧预览运行通过；静态资源引用与 GDScript 缩进检查通过。首次编辑器导入在共享环境退出时因默认 Godot 用户目录不可写而崩溃，改用 `/tmp` 用户目录后未复现；下一步由 Windows 实机确认板缝、墙地区分与纹理密度。

## 2026-07-19 墙地独立木板皮肤

- Windows 检查通过逐条木板的长度、高度、错缝和无方块重复逻辑，但程序短线纹理与概念图不一致；墙地共用相同绘制方法和近似色板，也使两层视觉上连成一块。
- 新增 CON-011：分别生成四种深色哑光墙板和四种较亮、带顶面受光的地板木板，使用纯洋红背景、Pillow 12.3.0 去背及最近邻缩放。墙板为 13 像素高，地板源皮肤为 16 像素高。
- `res://scripts/art_tests/warm_cabin_plank_preview.gd` 保留已确认的长短组合、至少 28 像素错缝和地板纵深行高，只把程序色块/短线替换为 `res://assets/candidates/warm_cabin/plank_skins_v1/` 的独立木板纹理。
- 墙后底色与地板底色分开，并继续使用深色墙脚；下一步检查纹理是否接近概念图、墙地是否清楚分层，以及地板木板在 10–16 像素动态行高下是否出现不可接受的压缩。
- Godot 4.7.1 已完成十二张源图/拆件的 headless 导入；共享环境仍只出现本地 TCP 监听限制。独立木板预览五帧运行与静态资源引用/缩进检查通过。

## 2026-07-19 逐条木板铺设逻辑

- 用户确认现有木材美术精度足够，根因是把包含多条木板的矩形地块重复铺设，导致即使接缝修复后仍能识别规则方块；停止继续修补方形纹理。
- 新增 `res://scenes/art_tests/warm_cabin_plank_preview.tscn` 与 `res://scripts/art_tests/warm_cabin_plank_preview.gd`。墙面和地板改由独立长短木板逐行构成，相邻行接头至少错开 28 像素，并使用固定种子维持确定性。
- 墙板固定为 13 像素行高；地板从后方 10 像素逐渐增加至前方 16 像素行高，表达正面低机位俯视纵深。每块板单独选择暖木变体并绘制不跨接头的短纹理段。
- 预览继续复用 CON-006 已通过比例检查的门、窗框和立柱，但不读取任何方形墙地纹理，也不替换主场景。下一步先验证木板构造逻辑与纹理密度，再决定是否把程序板面替换为手工像素木板变体。

## 2026-07-19 温暖木屋完整板行循环 v5

- Windows 检查确认 CON-009 左右接缝已消失，但上下接缝仍存在；v4 因此标记为 `Rejected`。原因是按整行平均色差选边不能保证横向木板缝处于相同板行相位。
- CON-010 保留 v4 已通过的左右裁切，只把上下边界改为完整板行周期：墙板从一条横缝后的板面开始并在后续完整横缝结束，地板采用相同原则。
- v5 仍直接裁自 v1、无缩放和新像素；墙板为 92×76，地板为 98×71 像素。本地 3×3 精确拼接未见左右或上下大接缝，结构预览已切换到 `res://assets/candidates/warm_cabin/structure_v5/`。

## 2026-07-19 温暖木屋自然循环边界 v4

- Windows 检查发现 CON-008 已去除黑框，但重复边缘变成白色线条。像素检查确认 v3 alpha 全不透明，问题来自边缘平均将亮度提高，并在重复时绘制成双亮线；不是 Godot 过滤错误。CON-008 标记为 `Rejected`。
- CON-009 改为从 v1 不透明内部搜索自然循环切点：在保留最大面积的约束下，选择左右列、上下行色差较低的边界，直接裁切，不缩放、不平均、不生成新像素。
- v4 墙板为 92×96 像素，地板为 98×90 像素；木板宽度和纹理密度与 v1 相同。本地 3×3 精确拼接未再出现黑框或白线，结构预览已切换到 `res://assets/candidates/warm_cabin/structure_v4/`。
- 下一步以 Windows Godot 预览确认实际窗口缩放下的边界；若仍有细微断纹，只对具体循环切点做手工像素微调。

## 2026-07-19 温暖木屋 v1 接缝修复

- Windows 检查否决 CON-007：虽然 v2 边界严格无缝，但木纹被压缩得过密，与已认可的 v1 视觉比例不一致。CON-007 已标记为 `Rejected`。
- 新增 CON-008，不再重新生成美术，只修复 `structure_v1/wall_panel.png` 和 `structure_v1/floor_panel.png`。各裁掉 1 像素外围展示边框、最近邻恢复原尺寸，并仅平均处理两像素宽的对应边缘。
- v3 继续保持墙板 96×104、地板 104×96 像素和 v1 的木板密度；逐像素检查确认左右边、上下边完全相等。结构预览已切换到 `res://assets/candidates/warm_cabin/structure_v3/`，门窗等仍使用 v1。
- 下一步由 Windows 重复铺设确认接缝是否消失且密度保持自然；若仍有局部断纹，再只手工微调 v3 边缘，不改变内部木纹。

## 2026-07-19 温暖木屋墙地无缝重制

- Windows 视觉检查确认 CON-006 的木材风格、门窗、立柱、比例与天气分层可接受，唯一明显问题是墙板和地板重复后出现大接缝；该问题来自素材自带边框，不是 Godot 导入错误。
- 只重做墙板和地板，门、窗框、墙脚与立柱继续使用 v1。两张 v2 源图分别生成满画布无边框纹理，保存在 `res://assets/candidates/warm_cabin/structure_v2/`。
- 为获得可验证的周期边界，使用 Pillow 12.3.0 将源图最近邻缩放为半块纹理，再水平与垂直镜像组合成 96×104 墙板和 104×96 地板。逐像素检查确认两张纹理的左右边与上下边均完全相同。
- `res://scenes/art_tests/warm_cabin_structure_preview.tscn` 已切换到 v2 墙地，其他结构素材保持不变。下一步检查重复铺设后是否出现明显的中心镜像规律；边界无缝不代表视觉重复已经合格。

## 2026-07-19 温暖木屋结构层试制

- 基于已确认的 CON-005 布局风格生成墙板、地板、墙脚、立柱、入口门和空窗框六件结构候选；洋红源图、透明图集和六张最近邻缩放拆件均保存在 `res://assets/candidates/warm_cabin/`。
- 使用 Pillow 12.3.0 去背；透明图集四角 alpha 均为 0，整体 alpha 范围为 0–255。窗框中心保持透明，缺省晴天外景可独立绘制在窗框后方。
- 新增 `res://scenes/art_tests/warm_cabin_structure_preview.tscn`，按 1280×270 重复铺设墙板和地板，并叠加墙脚、门、两扇窗与立柱。预览故意不隐藏拼接线，用于判断 AI 生成纹理是否具备正式平铺条件。
- Godot 4.7.1 已完成八张 PNG 的 headless 编辑器导入；共享环境因禁止本地 TCP 监听输出编辑器诊断错误，但导入步骤完成。随后独立预览场景五帧运行与静态资源引用/缩进检查均通过。
- CON-006 仍为 `Candidate`，当前不得替换主场景。下一步先完成 Godot 导入和 Windows 视觉检查；若重复边缘明显，则保留风格而重制确定性平铺纹理，不继续用插画式拉伸掩盖问题。

## 2026-07-19 温暖木屋分层布局灰盒

- 新增隔离场景 `res://scenes/art_tests/warm_cabin_layout_blockout.tscn` 与绘制脚本 `res://scripts/art_tests/warm_cabin_layout_blockout.gd`，不替换当前主场景。
- 灰盒按 1280×270 基准实现 DEC-014：左侧入口、左中 400 像素宽短柜台、分离的点单/取餐标记、42 像素深连续店员工作区、右侧两组靠窗桌、四个高凳的前方长桌和最右侧壁炉。
- 放入两名 32×48 像素店员和一名同尺寸玩家比例尺，并用半透明色带标示主通道。长桌座位根据陪伴感反馈调整为后侧两个正面座位与左右各一个侧面座位，前侧不再安排背对观众的角色并完整保留通道。
- 灰盒目的只是验证角色容量、朝向、遮挡和家具密度，不代表正式颜色、碰撞或美术细节。
- Godot 4.7.1 headless 已成功加载该场景并运行五帧，静态资源引用与 GDScript 缩进检查通过。
- 下一步先在 Windows 以该测试场景检查完整画面；确认后再按照同一布局拆分正式墙地、柜台、窗景和家具素材。

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
