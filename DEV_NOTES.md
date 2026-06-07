# 开发笔记

## 项目状态 (2026-06-07)

### 已完成
- 核心循环: 招聘→开发→发售→赚钱
- 员工: 6种性格、士气、培训、解雇+遣散费
- 办公室: 5级升级、chibi精灵(0.35x缩放)、像素画家具
- 科技树(5项)、市场需求(季节)、竞争对手(3个AI)
- 16个随机事件、通知Toast、事件日志、确认对话框
- 游戏结束(破产)、存档/读档、速度控制(1x/2x/3x)
- 分辨率: 1920x1080

### 当前进行中
- 分辨率刚升级到1920x1080，布局已调整
- chibi精灵从frames/目录加载，自动居中统一画布
- UI面板已按比例放大

### 已知问题
- chibi精灵帧尺寸不一致(已被独立帧加载修复)
- 音效框架为空(audio_manager.gd placeholder)
- zpix.ttf字体未集成到ThemeManager

### 待开发方向
- 研发阶段交互决策
- 市场营销系统
- 合约/外包系统
- 员工事件对话
- 更多游戏类型解锁
- 游戏续作系统
- 研发进度动画、发售动画
- 背景音乐

### 素材资源
- assets/sprites/characters/ — 4角色chibi精灵(idle/walk/work各4帧)
- assets/fonts/zpix.ttf — 中文像素字体
- 注意: 每个动画帧尺寸不同，代码已处理

### Git
- 仓库: https://github.com/vafvfdA/indie_game_company_sim.git
- main分支
