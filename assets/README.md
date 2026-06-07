# Godot Chibi Scaled Assets (24x32)

这是根据你满意的 chibi 素材自动缩放后的 Godot 角色素材包。

## 目标规格
- 每帧固定大小：`24x32`
- 保持像素风：使用 Nearest Neighbor 缩放
- 所有角色、所有动画尺寸统一
- 输出单帧 PNG + 单行 Sprite Sheet

## 目录结构
```text
assets/sprites/characters/
├── programmer/
│   ├── idle.png
│   ├── walk.png
│   ├── work.png
│   └── frames/
├── artist/
├── designer/
└── musician/
```

## 每张 Sprite Sheet
- `idle.png`：96x32（4 帧，每帧 24x32）
- `walk.png`：96x32
- `work.png`：96x32

## 使用方法
1. 解压本压缩包
2. 将其中的 `assets/sprites/characters/` 直接覆盖到你的 Godot 项目同路径
3. 回到 Godot，等待资源重新导入
4. 建议在 Godot 导入设置中将 Filter 设为 Off / Nearest

## 说明
- 角色被缩放并居中到底部对齐，适合工位场景中的 24x32 员工尺寸
- 原图较大，因此缩小后会保留主要形象特征，但细节会有所简化
