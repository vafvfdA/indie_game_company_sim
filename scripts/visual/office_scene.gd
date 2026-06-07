extends Node2D

@onready var employees_node: Node2D = $Employees

var _desk_positions: Array[Vector2] = []
var _desk_nodes: Array[Dictionary] = []  # {base, monitor}
var _sprites: Dictionary = {}  # Employee -> EmployeeSprite
var _decoration_nodes: Array[Node] = []

const DESK_GAP_X := 270.0
const DESK_GAP_Y := 170.0
const DESK_COLS := 5
const OFFICE_START_X := 430.0
const OFFICE_START_Y := 390.0
const ENTRANCE := Vector2(960, 920)

const FLOOR_TOP := 150.0
const FLOOR_LEFT := 135.0
const FLOOR_RIGHT := 1785.0
const FLOOR_BACK := 245.0
const FLOOR_FRONT := 930.0

func _ready():
	_draw_floor()
	_draw_walls()
	_redraw_decorations()
	_setup_desks()
	GameManager.employee_hired.connect(_on_employee_hired)
	GameManager.employee_fired.connect(_on_employee_fired)
	GameManager.day_passed.connect(_on_day_passed)
	GameManager.game_shipped.connect(_on_game_shipped)
	GameManager.office_upgraded.connect(_on_office_upgraded)
	GameManager.game_loaded.connect(_on_game_loaded)

func _draw_floor():
	_add_poly([
		Vector2(FLOOR_LEFT, FLOOR_BACK),
		Vector2(FLOOR_RIGHT, FLOOR_BACK),
		Vector2(FLOOR_RIGHT - 245, FLOOR_FRONT),
		Vector2(FLOOR_LEFT + 245, FLOOR_FRONT),
	], Color("f2c37a"), -20)

	for y in range(int(FLOOR_BACK + 18), int(FLOOR_FRONT), 42):
		var line := Line2D.new()
		line.points = PackedVector2Array([Vector2(FLOOR_LEFT + 80, y), Vector2(FLOOR_RIGHT - 80, y)])
		line.width = 2
		line.default_color = Color("dca561", 0.45)
		line.z_index = -19
		add_child(line)

	for x in range(int(FLOOR_LEFT + 170), int(FLOOR_RIGHT - 130), 72):
		var line := Line2D.new()
		line.points = PackedVector2Array([Vector2(x, FLOOR_BACK + 8), Vector2(x - 220, FLOOR_FRONT - 20)])
		line.width = 2
		line.default_color = Color("e7b66c", 0.38)
		line.z_index = -19
		add_child(line)

func _draw_walls():
	_add_poly([
		Vector2(FLOOR_LEFT, FLOOR_TOP),
		Vector2(FLOOR_RIGHT, FLOOR_TOP),
		Vector2(FLOOR_RIGHT, FLOOR_BACK),
		Vector2(FLOOR_LEFT, FLOOR_BACK),
	], Color("fff5dc"), -18)
	_add_poly([
		Vector2(FLOOR_LEFT, FLOOR_TOP),
		Vector2(FLOOR_LEFT, FLOOR_BACK),
		Vector2(FLOOR_LEFT + 245, FLOOR_FRONT),
		Vector2(FLOOR_LEFT + 245, FLOOR_FRONT - 130),
	], Color("f8e7c4"), -18)
	_add_poly([
		Vector2(FLOOR_RIGHT, FLOOR_TOP),
		Vector2(FLOOR_RIGHT, FLOOR_BACK),
		Vector2(FLOOR_RIGHT - 245, FLOOR_FRONT),
		Vector2(FLOOR_RIGHT - 245, FLOOR_FRONT - 130),
	], Color("f5dfb8"), -18)

	for x in range(250, 1650, 260):
		_add_window(Vector2(x, 178))

	# Company name on wall
	var name_label := Label.new()
	name_label.text = "独立工作室"
	name_label.position = Vector2(830, 74)
	name_label.add_theme_font_size_override("font_size", 32)
	name_label.add_theme_color_override("font_color", Color("5b4a7f"))
	name_label.z_index = -17
	add_child(name_label)

func _redraw_decorations():
	# Clear old decorations
	for node: Node in _decoration_nodes:
		node.queue_free()
	_decoration_nodes.clear()

	var level: int = GameManager.company.office_level

	_add_plant(Vector2(1690, 760))
	_add_bookshelf(Vector2(230, 225))

	if level >= 2:
		_add_plant(Vector2(1510, 250))
		_add_bookshelf(Vector2(1460, 210))

	if level >= 3:
		_add_coffee_machine(Vector2(255, 755))
		_add_whiteboard(Vector2(1180, 180))

	if level >= 4:
		_add_plant(Vector2(380, 760))
		_add_bookshelf(Vector2(1530, 620))

	if level >= 5:
		_add_trophy_shelf(Vector2(850, 165))
		_add_plant(Vector2(640, 255))

func _setup_desks():
	var count: int = GameManager.company.max_desks
	for i in count:
		var col: int = i % DESK_COLS
		var row: int = floori(float(i) / DESK_COLS)
		var pos := Vector2(OFFICE_START_X + col * DESK_GAP_X, OFFICE_START_Y + row * DESK_GAP_Y)
		_desk_positions.append(pos)
		_draw_desk(pos, i)

func _on_office_upgraded():
	_redraw_decorations()
	# Add new desks for the upgraded level
	var old_count: int = _desk_positions.size()
	var new_count: int = GameManager.company.max_desks
	for i in range(old_count, new_count):
		var col: int = i % DESK_COLS
		var row: int = floori(float(i) / DESK_COLS)
		var pos := Vector2(OFFICE_START_X + col * DESK_GAP_X, OFFICE_START_Y + row * DESK_GAP_Y)
		_desk_positions.append(pos)
		_draw_desk(pos, i)

func _draw_desk(pos: Vector2, _index: int):
	var base := Node2D.new()
	base.position = pos
	base.z_index = int(pos.y)
	add_child(base)

	_draw_chair(base, Vector2(0, 46))
	var screen := _draw_monitor(base, Vector2(0, -42), false)
	_draw_desk_body(base, Vector2.ZERO)

	_desk_nodes.append({"base": base, "monitor": screen})

func _on_employee_hired(emp: Employee):
	var index := _sprites.size()
	if index >= _desk_positions.size():
		return

	var sprite_script: Script = load("res://scripts/visual/employee_sprite.gd")
	var sprite := Node2D.new()
	sprite.set_script(sprite_script)
	employees_node.add_child(sprite)

	# Walk from entrance to desk
	sprite.setup(emp, _desk_positions[index])
	sprite.walk_to_desk(ENTRANCE)
	_sprites[emp] = sprite

	# Turn on monitor
	if index < _desk_nodes.size():
		_desk_nodes[index]["monitor"].color = Color("70d6ff")

func _on_employee_fired(emp: Employee):
	if emp in _sprites:
		var sprite: Node2D = _sprites[emp]
		var index: int = _sprites.values().find(sprite)
		if index >= 0 and index < _desk_nodes.size():
			_desk_nodes[index]["monitor"].color = Color("26405d")
		sprite.queue_free()
		_sprites.erase(emp)

func _on_day_passed():
	var working := GameManager.current_project != null
	for sprite: Node2D in _sprites.values():
		sprite.set_working(working)

func _on_game_shipped(_result: Dictionary):
	for sprite: Node2D in _sprites.values():
		sprite.celebrate()

func _on_game_loaded():
	# Clear all existing employee sprites before re-adding from save
	for sprite: Node2D in _sprites.values():
		sprite.queue_free()
	_sprites.clear()
	# Reset monitor screens
	for desk: Dictionary in _desk_nodes:
		desk["monitor"].color = Color("26405d")
	# Redraw decorations for current office level
	_redraw_decorations()

func _add_poly(points: Array, color: Color, z: int, parent: Node = null) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array(points)
	poly.color = color
	poly.z_index = z
	if parent:
		parent.add_child(poly)
	else:
		add_child(poly)
	return poly

func _add_rect(pos: Vector2, size: Vector2, color: Color, z: int, parent: Node = null) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = pos
	rect.size = size
	rect.color = color
	rect.z_index = z
	if parent:
		parent.add_child(rect)
	else:
		add_child(rect)
	return rect

func _add_window(pos: Vector2):
	_add_rect(pos, Vector2(98, 50), Color("d3b783"), -17)
	_add_rect(pos + Vector2(8, 8), Vector2(82, 34), Color("b8efff"), -16)
	for i in 3:
		_add_rect(pos + Vector2(18 + i * 22, 11), Vector2(8, 29), Color("ffffff", 0.55), -15)

func _draw_desk_body(parent: Node2D, pos: Vector2):
	var top := _add_poly([
		pos + Vector2(-88, -28),
		pos + Vector2(88, -28),
		pos + Vector2(122, 4),
		pos + Vector2(-122, 4),
	], Color("fff0cf"), -2, parent)
	var front := _add_poly([
		pos + Vector2(-122, 4),
		pos + Vector2(122, 4),
		pos + Vector2(108, 48),
		pos + Vector2(-108, 48),
	], Color("c98b58"), -1, parent)
	var side := _add_poly([
		pos + Vector2(88, -28),
		pos + Vector2(122, 4),
		pos + Vector2(108, 48),
		pos + Vector2(78, 16),
	], Color("a96d43"), -1, parent)
	var mat := _add_poly([
		pos + Vector2(-58, -18),
		pos + Vector2(58, -18),
		pos + Vector2(78, 0),
		pos + Vector2(-78, 0),
	], Color("8ad78b"), -1, parent)
	front.name = "DeskFront"
	side.name = "DeskSide"
	top.name = "DeskTop"
	mat.name = "DeskMat"
	_add_rect(pos + Vector2(-80, 16), Vector2(28, 22), Color("f5d7aa"), 0, parent)
	_add_rect(pos + Vector2(52, 16), Vector2(28, 22), Color("f5d7aa"), 0, parent)

func _draw_monitor(parent: Node2D, pos: Vector2, active: bool) -> ColorRect:
	_add_rect(pos + Vector2(-42, -38), Vector2(84, 54), Color("5c6172"), -5, parent)
	var screen_color := Color("70d6ff") if active else Color("26405d")
	var screen := _add_rect(pos + Vector2(-34, -31), Vector2(68, 38), screen_color, -4, parent)
	_add_rect(pos + Vector2(-8, 16), Vector2(16, 16), Color("5c6172"), -4, parent)
	_add_rect(pos + Vector2(-30, 30), Vector2(60, 8), Color("3e4352"), -4, parent)
	_add_rect(pos + Vector2(54, 2), Vector2(28, 8), Color("f5f0dc"), -4, parent)
	_add_rect(pos + Vector2(54, 14), Vector2(40, 8), Color("f5f0dc"), -4, parent)
	return screen

func _draw_chair(parent: Node2D, pos: Vector2):
	_add_poly([
		pos + Vector2(-44, -20),
		pos + Vector2(44, -20),
		pos + Vector2(54, 18),
		pos + Vector2(-54, 18),
	], Color("87909d"), -8, parent)
	_add_poly([
		pos + Vector2(-38, -58),
		pos + Vector2(38, -58),
		pos + Vector2(44, -18),
		pos + Vector2(-44, -18),
	], Color("a6aeb8"), -9, parent)
	_add_rect(pos + Vector2(-8, 16), Vector2(16, 36), Color("5f6875"), -7, parent)
	_add_rect(pos + Vector2(-34, 48), Vector2(68, 10), Color("5f6875"), -7, parent)

func _add_plant(pos: Vector2):
	var holder := Node2D.new()
	holder.position = pos
	holder.z_index = int(pos.y)
	add_child(holder)
	_decoration_nodes.append(holder)
	_add_rect(Vector2(-28, 38), Vector2(56, 36), Color("9b5d2e"), 0, holder)
	_add_rect(Vector2(-18, 28), Vector2(36, 14), Color("c0793b"), 1, holder)
	for p in [Vector2(-34, 8), Vector2(-16, -14), Vector2(8, -18), Vector2(30, 2), Vector2(0, 8)]:
		_add_poly([
			p + Vector2(0, -28),
			p + Vector2(34, -4),
			p + Vector2(0, 22),
			p + Vector2(-34, -4),
		], Color("32b85f"), 2, holder)

func _add_bookshelf(pos: Vector2):
	var shelf := Node2D.new()
	shelf.position = pos
	shelf.z_index = int(pos.y)
	add_child(shelf)
	_decoration_nodes.append(shelf)
	_add_rect(Vector2(0, 0), Vector2(138, 102), Color("a66a3d"), 0, shelf)
	_add_rect(Vector2(10, 10), Vector2(118, 24), Color("f7d46b"), 1, shelf)
	_add_rect(Vector2(10, 42), Vector2(118, 24), Color("78c7f5"), 1, shelf)
	_add_rect(Vector2(10, 74), Vector2(118, 18), Color("e96b84"), 1, shelf)
	for x in range(28, 122, 28):
		_add_rect(Vector2(x, 8), Vector2(8, 86), Color("704321"), 2, shelf)

func _add_coffee_machine(pos: Vector2):
	var machine := Node2D.new()
	machine.position = pos
	machine.z_index = int(pos.y)
	add_child(machine)
	_decoration_nodes.append(machine)
	_add_rect(Vector2(-34, -54), Vector2(68, 108), Color("d9e5ee"), 0, machine)
	_add_rect(Vector2(-22, -40), Vector2(44, 34), Color("70d6ff"), 1, machine)
	_add_rect(Vector2(-18, 12), Vector2(36, 22), Color("5a6170"), 1, machine)

func _add_whiteboard(pos: Vector2):
	var board := Node2D.new()
	board.position = pos
	board.z_index = -16
	add_child(board)
	_decoration_nodes.append(board)
	_add_rect(Vector2(0, 0), Vector2(210, 96), Color("d6c69a"), 0, board)
	_add_rect(Vector2(10, 10), Vector2(190, 76), Color("fffdf1"), 1, board)
	for i in 4:
		_add_rect(Vector2(36 + i * 32, 32 + (i % 2) * 12), Vector2(18, 6), Color("e94560"), 2, board)

func _add_trophy_shelf(pos: Vector2):
	var shelf := Node2D.new()
	shelf.position = pos
	shelf.z_index = -16
	add_child(shelf)
	_decoration_nodes.append(shelf)
	_add_rect(Vector2(0, 54), Vector2(250, 18), Color("9b6a40"), 0, shelf)
	for x in [35, 98, 160]:
		_add_poly([
			Vector2(x, 0),
			Vector2(x + 28, 16),
			Vector2(x + 18, 50),
			Vector2(x - 18, 50),
			Vector2(x - 28, 16),
		], Color("ffd35a"), 1, shelf)
