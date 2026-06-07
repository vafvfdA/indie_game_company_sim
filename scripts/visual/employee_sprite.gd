extends Node2D

var employee_data: Employee
var desk_position: Vector2
var is_working: bool = false

var _sprite: AnimatedSprite2D
var _name_label: Label
var _tween: Tween

const SPRITE_SCALE := 0.36

func setup(emp: Employee, pos: Vector2):
	employee_data = emp
	desk_position = pos
	position = pos
	z_index = int(pos.y) + 1

	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = _build_frames(emp.role)
	_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	_sprite.position = Vector2(0, -35)
	_sprite.z_index = -3  # behind monitor & desk, above chair
	add_child(_sprite)

	var shadow := ColorRect.new()
	shadow.color = Color(0, 0, 0, 0.18)
	shadow.size = Vector2(62, 18)
	shadow.position = Vector2(-31, 18)
	shadow.z_index = -4
	add_child(shadow)

	_name_label = Label.new()
	_name_label.text = emp.name
	_name_label.position = Vector2(-42, 76)
	_name_label.custom_minimum_size = Vector2(84, 22)
	_name_label.add_theme_font_size_override("font_size", 14)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_name_label)

	_sprite.play("idle")

	tree_exiting.connect(_kill_tween)

func _build_frames(role: String) -> SpriteFrames:
	# Try loading individual frames from frames/ directory
	var base_path := "res://assets/sprites/characters/%s/frames/" % role
	var anim_info: Dictionary = {
		"idle": {"count": 4, "fps": 6.0},
		"walk": {"count": 4, "fps": 8.0},
		"work": {"count": 4, "fps": 4.0},
	}

	# Check if frames directory exists for this role
	var first_frame_path := base_path + "idle/idle_1.png"
	if not ResourceLoader.exists(first_frame_path):
		# Fallback: try sprite sheets
		return _build_from_sheets(role)

	# First pass: find max frame dimensions across all animations
	var max_w: int = 0
	var max_h: int = 0
	for anim_name: String in anim_info:
		var count: int = anim_info[anim_name]["count"]
		for i in count:
			var path := base_path + "%s/%s_%d.png" % [anim_name, anim_name, i + 1]
			if ResourceLoader.exists(path):
				var tex: Texture2D = load(path)
				var img: Image = tex.get_image()
				max_w = maxi(max_w, img.get_width())
				max_h = maxi(max_h, img.get_height())

	if max_w == 0 or max_h == 0:
		return _build_pixel_frames(role)

	# Second pass: load frames, center on uniform canvas
	var sf := SpriteFrames.new()
	for anim_name: String in anim_info:
		var count: int = anim_info[anim_name]["count"]
		var fps: float = anim_info[anim_name]["fps"]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, fps)
		sf.set_animation_loop(anim_name, true)

		for i in count:
			var path := base_path + "%s/%s_%d.png" % [anim_name, anim_name, i + 1]
			if ResourceLoader.exists(path):
				var tex: Texture2D = load(path)
				var img: Image = tex.get_image()
				# Create uniform canvas and center frame
				var canvas := Image.create(max_w, max_h, false, Image.FORMAT_RGBA8)
				var ox: int = (max_w - img.get_width()) / 2
				var oy: int = (max_h - img.get_height()) / 2
				canvas.blit_rect(img, Rect2i(0, 0, img.get_width(), img.get_height()), Vector2i(ox, oy))
				var frame_tex := ImageTexture.create_from_image(canvas)
				sf.add_frame(anim_name, frame_tex)

	return sf

func _build_from_sheets(role: String) -> SpriteFrames:
	# Fallback: try loading from spritesheet PNGs
	var base_path := "res://assets/sprites/characters/%s/" % role
	var sheets: Dictionary = {}

	for anim: String in ["idle", "walk", "work"]:
		var path := base_path + anim + ".png"
		if ResourceLoader.exists(path):
			sheets[anim] = {"path": path, "fps": 8.0 if anim != "work" else 4.0}

	if sheets.size() > 0:
		var first_path: String = sheets.values()[0]["path"]
		var tex: Texture2D = load(first_path)
		var img: Image = tex.get_image()
		var frame_w: int = img.get_width()
		var frame_h: int = img.get_height()
		return SpriteSheetLoader.load_character(sheets, frame_w, frame_h)

	# Final fallback: programmatic pixel art
	return _build_pixel_frames(role)

func _build_pixel_frames(role: String) -> SpriteFrames:
	var sf := SpriteFrames.new()

	sf.add_animation("idle")
	sf.set_animation_speed("idle", 1)
	sf.add_frame("idle", PixelBuilder.char_idle(role))

	sf.add_animation("walk")
	sf.set_animation_speed("walk", 4)
	sf.add_frame("walk", PixelBuilder.char_walk1(role))
	sf.add_frame("walk", PixelBuilder.char_walk2(role))

	sf.add_animation("work")
	sf.set_animation_speed("work", 3)
	sf.add_frame("work", PixelBuilder.char_work1(role))
	sf.add_frame("work", PixelBuilder.char_work2(role))

	return sf

func set_working(working: bool):
	if is_working == working:
		return
	is_working = working
	if working:
		_sprite.play("work")
	else:
		_sprite.play("idle")

func walk_to_desk(entrance_pos: Vector2):
	position = entrance_pos
	_sprite.play("walk")

	if entrance_pos.x > desk_position.x:
		_sprite.flip_h = true
	else:
		_sprite.flip_h = false

	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "position", desk_position, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.finished.connect(func():
		if not is_instance_valid(self):
			return
		_sprite.flip_h = false
		_sprite.play("idle")
	)

func celebrate():
	_kill_tween()
	_sprite.play("idle")
	_tween = create_tween()
	_tween.tween_property(self, "position:y", position.y - 20, 0.15).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:y", desk_position.y, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	_tween.finished.connect(func():
		if not is_instance_valid(self):
			return
		if is_working:
			_sprite.play("work")
		else:
			_sprite.play("idle")
	)

func _kill_tween():
	if _tween and _tween.is_valid():
		_tween.kill()
