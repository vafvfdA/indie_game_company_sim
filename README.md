# 独立游戏公司模拟经营游戏

## 快速开始

1. 打开 Godot 4.x → 导入 `project.godot`
2. 按 F5 运行
3. 操作顺序：招聘员工 → 创建项目 → 点击开始 → 等待开发完成 → 查看发售结果

## 项目结构

```
game/
├── project.godot                        # Godot 项目配置（入口）
├── README.md                            # 本文件
├── assets/
│   └── fonts/
│       └── zpix.ttf                     # 像素字体（最像素）
├── scenes/
│   └── main/
│       └── main.tscn                    # 主场景
└── scripts/
    ├── autoload/
    │   ├── game_manager.gd              # 核心管理器（全局单例）
    │   ├── event_system.gd              # 随机事件系统（全局单例）
    │   └── theme_manager.gd             # 像素UI主题（全局单例）
    ├── models/
    │   ├── employee.gd                  # 员工数据模型
    │   ├── project.gd                   # 游戏项目模型
    │   └── company.gd                   # 公司数据模型
    ├── systems/
    │   └── time_system.gd               # 时间推进系统（Timer驱动）
    ├── visual/
    │   ├── pixel_builder.gd             # 像素画生成工具（静态类）
    │   ├── employee_sprite.gd           # 员工精灵（AnimatedSprite2D）
    │   └── office_scene.gd              # 办公室场景管理
    └── ui/
        ├── hud.gd                       # 主界面控制
        ├── project_panel.gd             # 创建项目弹窗
        ├── hire_panel.gd                # 招聘弹窗
        └── result_panel.gd              # 发售结果弹窗
```

## 核心架构

### 场景层级

```
Main (Control + hud.gd)
├── OfficeLayer (CanvasLayer, layer=-1)    # 2D办公室场景（渲染在UI后面）
│   └── OfficeScene (Node2D)
│       ├── 地板/墙壁（像素纹理 Sprite2D）
│       ├── 家具（桌子/显示器/椅子 Sprite2D）
│       └── Employees (Node2D)            # 动态生成的员工精灵
├── TopBar (PanelContainer)                # 顶部状态条：标题/状态/速度
├── BottomBar (PanelContainer)             # 底部操作条：事件通知/按钮
├── TimeSystem (Node)
└── 弹窗面板 (ProjectPanel/HirePanel/ResultPanel)
```

### 数据流

```
用户点击按钮
  → hud.gd 响应 pressed 信号
    → 调用 game_manager.gd 的功能函数
      → 操作 company.gd / project.gd 的数据
        → 触发信号 day_passed / game_shipped / employee_hired
          → office_scene.gd 更新办公室视觉
          → hud.gd 更新界面显示
```

### 像素画系统

`pixel_builder.gd` 是静态工具类，用代码定义像素图案并转换为 ImageTexture：
- 角色：12x16 像素，3 套动画帧（idle/walk/work）
- 家具：桌子、显示器、椅子、书架、盆栽等均为程序化生成
- 所有纹理 3 倍缩放，Nearest 插值保持像素锐利

### 时间系统

```
点击"开始" → time_system.gd 的 Timer 启动
  → 每1秒触发 _on_tick()
    → game_manager.advance_day()
      → current_day += 1
      → 如果有项目：推进开发进度
      → 每30天：扣工资、触发月度事件
      → 项目完成：计算销量、发售后信号
```

## 各文件说明

### models/ — 数据层

| 文件 | class_name | 核心属性 | 核心方法 |
|------|-----------|----------|----------|
| employee.gd | Employee | name, role, skill, salary, morale | work(), gain_experience(), get_role_name() |
| project.gd | GameProject | game_name, genre, theme, progress, quality | develop(), get_total_progress() |
| company.gd | Company | name, money, reputation, employees | hire(), fire(), pay_salaries() |

**Employee 职业类型：**
- `programmer` 程序员 → 蓝色衬衫，开发 program 进度，偶尔产生 Bug
- `artist` 美术 → 粉色衬衫，开发 art 进度
- `designer` 策划 → 青色衬衫，开发 design 进度
- `musician` 音乐 → 黄色衬衫，开发 audio 进度

### autoload/ — 全局单例

**game_manager.gd (GameManager)**
- 管理公司、项目、员工池
- 关键信号：`day_passed`, `game_shipped`, `employee_hired`, `employee_fired`
- 关键函数：`start_project()`, `advance_day()`, `hire_employee()`, `get_employee_pool()`

**event_system.gd (EventSystem)**
- `check_random_events()` → 每天检查是否触发随机事件
- `emit_event(text)` → 记录并广播事件

**theme_manager.gd (ThemeManager)**
- 加载 Zpix 像素字体
- 运行时构建像素风格主题（硬边框、深色配色）
- 应用到根节点，所有 UI 控件自动继承

### visual/ — 视觉层

**pixel_builder.gd (PixelBuilder)**
- 静态工具类，无需实例化
- `make_texture()` → 从颜色数组生成 ImageTexture
- `make_from_map()` → 从字符映射图生成纹理
- 预定义：角色帧、家具纹理、地板/墙壁纹理

**employee_sprite.gd**
- AnimatedSprite2D 基础的员工精灵
- 动画状态：idle（待机）、walk（走路）、work（打字）
- `walk_to_desk()` → 从门口走到工位
- `celebrate()` → 发售庆祝跳跃

**office_scene.gd**
- 管理办公室视觉布局
- 像素画地板/墙壁/家具
- 连接 GameManager 信号自动更新

### ui/ — 界面层

**hud.gd（绑定在 Main 节点）**
- 连接所有按钮的 pressed 信号
- 连接 GameManager 的信号更新状态
- TopBar 显示状态，BottomBar 显示事件和按钮

**弹窗面板：**
- `ProjectPanel` → 创建项目（类型/题材/平台选择）
- `HirePanel` → 招聘员工（随机候选人列表）
- `ResultPanel` → 发售结果（评分/销量/收入）

## 游戏数值设计

### 初始状态

- 资金：50000 元
- 员工：0 人
- 声望：0

### 员工薪资
- 基础 500 + 技能等级 × 500 + 随机 0~500

### 项目开发
- 每个方向（设计/程序/美术/音效）需要 1000 点进度
- 员工每天贡献 = 技能 × 10 × 士气加成 × 经验加成
- 程序员有 10% 概率产生 Bug，降低技术评分

### 兼容性加成（类型 × 题材）
| 类型 | 最佳题材 | 加成 |
|------|----------|------|
| RPG | 武侠 | 1.3x |
| SLG | 历史 | 1.3x |
| ACT | 武侠 | 1.2x |
| AVG | 恐怖 | 1.3x |
| STG | 科幻 | 1.2x |
| PUZ | 日常 | 1.2x |
| SIM | 都市 | 1.3x |
| SPG | 都市 | 1.1x |

### 评分 → 等级
| 分数 | 等级 |
|------|------|
| 90+ | S |
| 75-89 | A |
| 60-74 | B |
| 40-59 | C |
| 20-39 | D |
| <20 | F |

### 销量公式
```
基础销量 = 评分² × 10
最终销量 = 基础销量 × (1 + 声望×0.01) × 平台倍率
收入 = 销量 × 10 元/份

平台倍率：PC=1.0, 主机=1.5, 手机=2.0
```

## 扩展指南

### 替换像素画为正式美术资源
1. 在 `pixel_builder.gd` 中添加新的纹理生成函数，或直接加载外部图片
2. `employee_sprite.gd` 的 `_build_frames()` 替换为加载 SpriteSheet
3. `office_scene.gd` 的家具纹理替换为外部素材

### 添加新职业
1. `employee.gd` 的 `get_role_name()` 加匹配项
2. `pixel_builder.gd` 的 `_char_palette()` 加角色颜色
3. `game_manager.gd` 的 `get_employee_pool()` 的 role_list 加类型
4. `project.gd` 的 `develop()` 加对应贡献逻辑

### 添加新功能
- 存档系统：用 FileAccess 保存/加载 company 数据
- 科技树：在 game_manager 中添加 research 变量
- 办公室升级：在 company 中添加 office_level 逻辑
- 更多事件：在 event_system.gd 的 random_events 数组中添加

## 技术栈

- 引擎：Godot 4.6 (GL Compatibility)
- 像素字体：Zpix（最像素）v3.1.11
- 渲染：Nearest 纹理过滤，像素锐利
- 架构：信号驱动 MVC，CanvasLayer 分层渲染
