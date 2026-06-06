extends Node2D

var employee_data: Employee
var desk_position: Vector2
var is_working: bool = false

var _sprite: AnimatedSprite2D
var _name_label: Label
var _tween: Tween

func setup(emp: Employee, pos: Vector2):
	employee_data = emp
	desk_position = pos
	position = pos

	# Create AnimatedSprite2D
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = _build_frames(emp.role)
	_sprite.scale = Vector2(2, 2)
	_sprite.position = Vector2(0, -20)
	add_child(_sprite)

	# Name label below character
	_name_label = Label.new()
	_name_label.text = emp.name
	_name_label.position = Vector2(-18, 12)
	_name_label.add_theme_font_size_override("font_size", 10)
	add_child(_name_label)

	_sprite.play("idle")

func _build_frames(role: String) -> SpriteFrames:
	var sf := SpriteFrames.new()

	# Idle
	sf.add_animation("idle")
	sf.set_animation_speed("idle", 1)
	sf.add_frame("idle", PixelBuilder.char_idle(role))

	# Walk
	sf.add_animation("walk")
	sf.set_animation_speed("walk", 4)
	sf.add_frame("walk", PixelBuilder.char_walk1(role))
	sf.add_frame("walk", PixelBuilder.char_walk2(role))

	# Work
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

	# Flip sprite based on direction
	if entrance_pos.x > desk_position.x:
		_sprite.flip_h = true
	else:
		_sprite.flip_h = false

	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "position", desk_position, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_tween.finished.connect(func():
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
		if is_working:
			_sprite.play("work")
		else:
			_sprite.play("idle")
	)

func _kill_tween():
	if _tween and _tween.is_valid():
		_tween.kill()
