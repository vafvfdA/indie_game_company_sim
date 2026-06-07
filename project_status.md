---
name: Project Status & Architecture
description: Game Dev Story-style indie game company sim in Godot 4.6 - current state, architecture, known issues
type: project
originSessionId: b8a395b0-e5ea-405d-9b01-ea871c377ae7
---
## 项目概览
独立游戏公司模拟器（Game Dev Story风格），Godot 4.6 + GDScript，GL Compatibility渲染器。

## 技术架构
- **Autoload单例**: GameManager, EventSystem, ThemeManager, AudioManager
- **CanvasLayer架构**: OfficeLayer(layer=-1) 放办公室2D场景，UI在layer=0
- **信号驱动**: GameManager发射信号 → UI面板监听
- **像素画系统**: PixelBuilder程序化生成所有视觉素材（地板、墙壁、家具、角色）
- **精灵表加载**: SpriteSheetLoader + PixelBuilder fallback

## 文件结构
```
scripts/
├── autoload/     - game_manager.gd, event_system.gd, audio_manager.gd, theme_manager.gd
├── models/       - company.gd, employee.gd, project.gd, tech_tree.gd, rival_company.gd
├── systems/      - time_system.gd, save_manager.gd
├── ui/           - hud.gd, hire_panel.gd, project_panel.gd, train_panel.gd, tech_panel.gd,
│                   manage_panel.gd, log_panel.gd, confirm_dialog.gd, game_over_panel.gd,
│                   notification_system.gd, result_panel.gd
└── visual/       - office_scene.gd, employee_sprite.gd, pixel_builder.gd, sprite_sheet_loader.gd
scenes/main/      - main.tscn
assets/           - sprites/characters/{programmer,artist,designer,musician}/, fonts/zpix.ttf
```

## 已完成的功能
1. 核心循环: 招聘 → 开发项目 → 发售 → 赚钱
2. 员工系统: 6种性格、士气、培训、解雇+遣散费
3. 办公室: 5级升级、视觉装饰、chibi精灵
4. 科技树: 5项研究
5. 市场需求: 季节性类型/题材加成
6. 竞争对手: 3个AI对手、月度更新、排名
7. 16个随机事件
8. 通知/Toast系统、事件日志、确认对话框
9. 游戏结束（破产条件）、存档/读档
10. 速度控制(1x/2x/3x)

## 当前状态 (2026-06-07)
- 刚完成分辨率升级 1280x720 → 1920x1080
- 办公室布局放大: 工位间距 220x180, 5列
- chibi精灵缩放 0.35x (~117px高)
- **已知问题**: chibi精灵尺寸不一致(每个动画帧大小不同)，已通过独立帧加载+居中画布修复

## 素材资源
- assets/sprites/characters/ 下有4个角色的chibi精灵(idle/walk/work各4帧)
- 精灵帧尺寸不统一: programmer idle 229x335, walk 213x324, work 294x347
- assets/fonts/zpix.ttf: 中文像素字体
- 无音频素材

## GDScript严格类型
- 全面使用类型标注，避免Variant推断错误
- `for emp: Employee in array`, `var m: Dictionary = dict[key]`
- Array[Employee] typed arrays
- Lambda中使用is_instance_valid检查防止节点释放后崩溃
