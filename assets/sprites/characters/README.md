# Character Sprite Sheets

Place character sprite sheets in subdirectories per role.

## Directory Structure
```
assets/sprites/characters/
├── programmer/
│   ├── idle.png      # idle animation (single row, frames left to right)
│   ├── walk.png      # walk animation (single row)
│   └── work.png      # work animation (single row)
├── artist/
│   ├── idle.png
│   ├── walk.png
│   └── work.png
├── designer/
│   └── ...
└── musician/
    └── ...
```

## Sprite Sheet Format
- PNG format, single row of frames
- All frames same size (e.g., 32x32 per frame)
- Frames arranged left to right in a row
- Example: a 128x32 PNG with 4 frames = each frame is 32x32

## Recommended Size
- 32x32 per frame (best balance of detail and pixel art feel)
- 16x16 also works (more retro)

## Naming Convention
- `idle.png` — standing still animation (2-4 frames)
- `walk.png` — walking animation (4-8 frames)
- `work.png` — working/typing animation (2-4 frames)

## Where to Find Free Sprites
- https://itch.io/game-assets/free/tag-pixel-art
- https://opengameart.org
- Search for "pixel character sprite sheet 32x32"

## Fallback
If no sprite sheets are found, the game uses programmatic pixel art (PixelBuilder).
