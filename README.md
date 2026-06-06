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
├── scenes/
│   └── main/
│       └── main.tscn                    # 主场景（UI布局，所有节点在这里）
└── scripts/
    ├── autoload/
    │   ├── game_manager.gd              # 核心管理器（全局单例）
    │   └── event_system.gd              # 随机事件系统（全局单例）
    ├── models/
    │   ├── employee.gd                  # 员工数据模型
    │   ├── project.gd                   # 游戏项目模型
    │   └── company.gd                   # 公司数据模型
    ├── systems/
    │   └── time_system.gd               # 时间推进系统（Timer驱动）
    └── ui/
        ├── hud.gd                       # 主界面控制（绑定在Main节点）
        ├── project_panel.gd             # 创建项目弹窗
        ├── hire_panel.gd                # 招聘弹窗
        └── result_panel.gd              # 发售结果弹窗
```

## 核心架构

### 数据流

```
用户点击按钮
  → hud.gd 响应 pressed 信号
    → 调用 game_manager.gd 的功能函数
      → 操作 company.gd / project.gd 的数据
        → 触发信号 day_passed / game_shipped
          → hud.gd 更新界面显示
```

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
- `programmer` 程序员 → 开发 program 进度，偶尔产生 Bug
- `artist` 美术 → 开发 art 进度
- `designer` 策划 → 开发 design 进度
- `musician` 音乐 → 开发 audio 进度

### autoload/ — 全局单例

**game_manager.gd (GameManager)**
- 任何脚本都可以直接调用 `GameManager.xxx`
- 管理公司、项目、员工池
- 关键函数：
  - `start_project(name, genre, theme, platform)` → 创建项目
  - `advance_day()` → 推进一天
  - `hire_employee(emp)` → 雇佣员工
  - `get_employee_pool()` → 生成6个随机可招聘员工
  - `get_status_text()` → 返回状态文字

**event_system.gd (EventSystem)**
- `check_random_events()` → 每天检查是否触发随机事件
- `emit_event(text)` → 记录并广播事件

### systems/ — 游戏系统

**time_system.gd**
- 绑定在 Main 场景的 TimeSystem 节点上
- `start()` → 启动 Timer
- `stop()` → 停止 Timer
- Timer 每隔 tick_interval 秒触发 advance_day()

### ui/ — 界面层

**hud.gd（绑定在 Main 节点）**
- 连接所有按钮的 pressed 信号
- 连接 GameManager 的 day_passed / game_shipped 信号
- `_update_ui()` → 刷新状态文字

**弹窗面板：**
- `show_project_panel()` → 显示项目创建面板
- `show_hire_panel()` → 显示招聘面板
- `show_result(result)` → 显示发售结果

## 场景节点树 (main.tscn)

```
Main (Control + hud.gd)
├── BG (ColorRect)                    # 背景色
├── VBox (VBoxContainer)
│   ├── TopBar (HBoxContainer)
│   │   ├── Title (Label)             # "独立游戏公司模拟"
│   │   ├── Spacer (Control)
│   │   └── SpeedLabel (Label)        # "速度: 1x"
│   ├── HSep (HSeparator)
│   ├── StatusLabel (Label)           # 状态信息（资金/日期/员工）
│   ├── HSep2 (HSeparator)
│   ├── EventLabel (Label)            # 事件通知
│   └── ButtonBar (HBoxContainer)
│       ├── BtnStart (Button)         # "开始"
│       ├── BtnPause (Button)         # "暂停"
│       ├── BtnProject (Button)       # "项目"
│       └── BtnHire (Button)          # "招聘"
├── TimeSystem (Node + time_system.gd)
├── ProjectPanel (Control + project_panel.gd)  # 默认隐藏
├── HirePanel (Control + hire_panel.gd)        # 默认隐藏
└── ResultPanel (Control + result_panel.gd)    # 默认隐藏
```

## 游戏数值设计

### 初始状态

- 资金：50000 元
- 员工：0 人
- 声望：0

### 员工薪资
- 基础 500 + 技能等级 × 500 + 随机 0~500
- 技能1级 ≈ 1000~1500/月，技能5级 ≈ 3000~3500/月

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

### 添加新职业
1. `employee.gd` 的 `get_role_name()` 加匹配项
2. `game_manager.gd` 的 `get_employee_pool()` 的 role_list 加类型
3. `project.gd` 的 `develop()` 加对应贡献逻辑

### 添加新游戏类型/题材
1. `game_manager.gd` 的 `genres` / `themes` 数组加值
2. `compatibility` 字典加对应兼容性数据

### 添加新功能
- 存档系统：用 FileAccess 保存/加载 company 数据
- 科技树：在 game_manager 中添加 research 变量
- 办公室升级：在 company 中添加 office_level 逻辑
- 更多事件：在 event_system.gd 的 random_events 数组中添加

## 调试

所有关键函数都有 `print()` 输出。运行时查看 Godot 编辑器底部的 **输出面板** 查看日志。

## 已知问题

- Windows 上可能有 WASAPI 音频错误 → 项目设置 → 音频 → 驱动 → 改为 WinSound
- 如果界面显示"加载中"不更新 → 检查 Main 节点是否绑定了 hud.gd 脚本
