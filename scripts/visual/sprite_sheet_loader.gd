class_name SpriteSheetLoader
extends RefCounted

## Loads a PNG sprite sheet and extracts frames into SpriteFrames.
##
## Sprite sheet format: grid of equal-sized frames.
## Example: a 128x128 PNG with 32x32 frames = 4x4 grid = 16 frames.
##
## Usage:
##   var sf = SpriteSheetLoader.load_sheet("res://assets/sprites/characters/idle.png", 32, 32, 4)
##   # sf is a SpriteFrames with frames extracted from the grid (row by row, left to right)

static func load_sheet(path: String, frame_w: int, frame_h: int, frame_count: int = -1, fps: float = 8.0) -> SpriteFrames:
	var sf := SpriteFrames.new()

	if not ResourceLoader.exists(path):
		push_warning("SpriteSheetLoader: file not found: " + path)
		return sf

	var tex: Texture2D = load(path)
	var img: Image = tex.get_image()
	var img_w: int = img.get_width()
	var img_h: int = img.get_height()

	var cols: int = img_w / frame_w
	var rows: int = img_h / frame_h
	var total: int = cols * rows

	if frame_count < 0:
		frame_count = total
	else:
		frame_count = mini(frame_count, total)

	var default_anim := &"default"
	sf.add_animation(default_anim)
	sf.set_animation_speed(default_anim, fps)
	sf.set_animation_loop(default_anim, true)

	for i in frame_count:
		var col: int = i % cols
		var row: int = i / cols
		var rect := Rect2i(col * frame_w, row * frame_h, frame_w, frame_h)
		var frame_img := img.get_region(rect)
		var frame_tex := ImageTexture.create_from_image(frame_img)
		sf.add_frame(default_anim, frame_tex)

	return sf

## Load multiple sheets (idle, walk, work) into one SpriteFrames with named animations.
## sheets: Dictionary of {"idle": path, "walk": path, "work": path}
## Each value can be a String (path) or Dictionary {"path": String, "frames": int, "fps": float}
static func load_character(sheets: Dictionary, frame_w: int, frame_h: int) -> SpriteFrames:
	var sf := SpriteFrames.new()

	for anim_name: String in sheets:
		var info: Variant = sheets[anim_name]
		var path: String
		var frame_count: int = -1
		var fps: float = 8.0

		if info is String:
			path = info
		elif info is Dictionary:
			path = info.get("path", "")
			frame_count = info.get("frames", -1)
			fps = info.get("fps", 8.0)

		if not ResourceLoader.exists(path):
			push_warning("SpriteSheetLoader: skipping missing sheet: " + path)
			continue

		var tex: Texture2D = load(path)
		var img: Image = tex.get_image()
		var img_w: int = img.get_width()
		var img_h: int = img.get_height()
		var cols: int = img_w / frame_w
		var total: int = cols * (img_h / frame_h)

		if frame_count < 0:
			frame_count = total
		else:
			frame_count = mini(frame_count, total)

		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, fps)
		sf.set_animation_loop(anim_name, anim_name != "work" or true)

		for i in frame_count:
			var col: int = i % cols
			var row: int = i / cols
			var rect := Rect2i(col * frame_w, row * frame_h, frame_w, frame_h)
			var frame_img := img.get_region(rect)
			var frame_tex := ImageTexture.create_from_image(frame_img)
			sf.add_frame(anim_name, frame_tex)

	return sf

## Check if a sprite sheet exists for the given role.
static func has_role_sprites(role: String) -> bool:
	var base := "res://assets/sprites/characters/%s/" % role
	return ResourceLoader.exists(base + "idle.png") or ResourceLoader.exists(base + "idle_0.png")
