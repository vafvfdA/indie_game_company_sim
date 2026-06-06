extends Node2D

@onready var employees_node: Node2D = $Employees

var _desk_positions: Array[Vector2] = []
var _desk_nodes: Array[Dictionary] = []  # {base, monitor_sprite}
var _sprites: Dictionary = {}  # Employee -> EmployeeSprite

const DESK_GAP_X := 150.0
const DESK_GAP_Y := 120.0
const DESK_COLS := 4
const OFFICE_START_X := 200.0
const OFFICE_START_Y := 260.0
const ENTRANCE := Vector2(640, 700)

func _ready():
	_draw_floor()
	_draw_walls()
	_draw_decorations()
	_setup_desks()
	GameManager.employee_hired.connect(_on_employee_hired)
	GameManager.employee_fired.connect(_on_employee_fired)
	GameManager.day_passed.connect(_on_day_passed)
	GameManager.game_shipped.connect(_on_game_shipped)

func _draw_floor():
	var floor_tex := PixelBuilder.floor_tile_texture()
	for tx in range(0, 1280, 16):
		for ty in range(120, 720, 16):
			var tile := Sprite2D.new()
			tile.texture = floor_tex
			tile.position = Vector2(tx + 8, ty + 8)
			tile.z_index = -10
			add_child(tile)

func _draw_walls():
	var wall_tex := PixelBuilder.wall_texture()
	for tx in range(0, 1280, 16):
		for ty in range(0, 120, 16):
			var tile := Sprite2D.new()
			tile.texture = wall_tex
			tile.position = Vector2(tx + 8, ty + 8)
			tile.z_index = -5
			add_child(tile)

	# Company name on wall
	var name_label := Label.new()
	name_label.text = "独立工作室"
	name_label.position = Vector2(520, 45)
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.z_index = -4
	add_child(name_label)

func _draw_decorations():
	# Bookshelf (left)
	var shelf_tex := PixelBuilder.bookshelf_texture()
	var shelf := Sprite2D.new()
	shelf.texture = shelf_tex
	shelf.position = Vector2(60, 180)
	shelf.scale = Vector2(2, 2)
	shelf.z_index = -3
	add_child(shelf)

	# Plant (right)
	var plant_tex := PixelBuilder.plant_texture()
	var plant := Sprite2D.new()
	plant.texture = plant_tex
	plant.position = Vector2(1200, 180)
	plant.scale = Vector2(2, 2)
	plant.z_index = -3
	add_child(plant)

	# Coffee machine (bottom left)
	var coffee_tex := PixelBuilder.coffee_machine_texture()
	var coffee := Sprite2D.new()
	coffee.texture = coffee_tex
	coffee.position = Vector2(60, 640)
	coffee.scale = Vector2(2, 2)
	coffee.z_index = -3
	add_child(coffee)

	# Whiteboard (top right)
	var wb_tex := PixelBuilder.whiteboard_texture()
	var wb := Sprite2D.new()
	wb.texture = wb_tex
	wb.position = Vector2(1100, 80)
	wb.scale = Vector2(2, 2)
	wb.z_index = -3
	add_child(wb)

	# Another plant (bottom right)
	var plant2 := Sprite2D.new()
	plant2.texture = plant_tex
	plant2.position = Vector2(1200, 640)
	plant2.scale = Vector2(2, 2)
	plant2.z_index = -3
	add_child(plant2)

func _setup_desks():
	for i in 8:
		var col := i % DESK_COLS
		var row := i / DESK_COLS
		var pos := Vector2(OFFICE_START_X + col * DESK_GAP_X, OFFICE_START_Y + row * DESK_GAP_Y)
		_desk_positions.append(pos)
		_draw_desk(pos, i)

func _draw_desk(pos: Vector2, _index: int):
	var base := Node2D.new()
	base.position = pos
	base.z_index = -2
	add_child(base)

	# Desk sprite
	var desk_tex := PixelBuilder.desk_texture()
	var desk_sp := Sprite2D.new()
	desk_sp.texture = desk_tex
	desk_sp.position = Vector2(0, 10)
	desk_sp.scale = Vector2(2, 2)
	base.add_child(desk_sp)

	# Chair sprite
	var chair_tex := PixelBuilder.chair_texture()
	var chair_sp := Sprite2D.new()
	chair_sp.texture = chair_tex
	chair_sp.position = Vector2(0, 40)
	chair_sp.scale = Vector2(2, 2)
	base.add_child(chair_sp)

	# Monitor sprite
	var mon_tex := PixelBuilder.monitor_texture(false)
	var mon_sp := Sprite2D.new()
	mon_sp.texture = mon_tex
	mon_sp.position = Vector2(0, -15)
	mon_sp.scale = Vector2(2, 2)
	base.add_child(mon_sp)

	_desk_nodes.append({"base": base, "monitor": mon_sp})

func _on_employee_hired(emp: Employee):
	var index := _sprites.size()
	if index >= _desk_positions.size():
		return

	var sprite_script = load("res://scripts/visual/employee_sprite.gd")
	var sprite := Node2D.new()
	sprite.set_script(sprite_script)
	employees_node.add_child(sprite)

	# Walk from entrance to desk
	sprite.setup(emp, _desk_positions[index])
	sprite.walk_to_desk(ENTRANCE)
	_sprites[emp] = sprite

	# Turn on monitor
	if index < _desk_nodes.size():
		_desk_nodes[index]["monitor"].texture = PixelBuilder.monitor_texture(true)

func _on_employee_fired(emp: Employee):
	if emp in _sprites:
		var index := _sprites.values().find(_sprites[emp])
		if index >= 0 and index < _desk_nodes.size():
			_desk_nodes[index]["monitor"].texture = PixelBuilder.monitor_texture(false)
		_sprites[emp].queue_free()
		_sprites.erase(emp)

func _on_day_passed():
	var working := GameManager.current_project != null
	for sprite in _sprites.values():
		sprite.set_working(working)

func _on_game_shipped(_result: Dictionary):
	for sprite in _sprites.values():
		sprite.celebrate()
