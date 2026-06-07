extends Control

@onready var employee_list: VBoxContainer = $Panel/VBox/ScrollContainer/EmployeeList
@onready var btn_refresh: Button = $Panel/VBox/BtnRefresh
@onready var btn_close: Button = $Panel/VBox/BtnClose
@onready var info_label: Label = $Panel/VBox/InfoLabel

var current_pool: Array = []

func _ready():
	btn_refresh.pressed.connect(_refresh_pool)
	btn_close.pressed.connect(_on_close)
	hide()

func show_hire_panel():
	_refresh_pool()
	show()

func _refresh_pool():
	for child: Node in employee_list.get_children():
		child.queue_free()

	current_pool = GameManager.get_employee_pool()

	for emp: Employee in current_pool:
		var row := _make_employee_row(emp)
		employee_list.add_child(row)

	info_label.text = "可招聘员工  资金: %d" % GameManager.company.money

func _make_employee_row(emp: Employee) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 88)
	row.add_theme_constant_override("separation", 12)

	row.add_child(_make_employee_preview(emp.role))

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.alignment = BoxContainer.ALIGNMENT_CENTER

	var name_label := Label.new()
	name_label.text = "%s  %s" % [emp.name, emp.get_role_name()]
	name_label.add_theme_font_size_override("font_size", 18)
	text_box.add_child(name_label)

	var stat_label := Label.new()
	stat_label.text = "技能 %d    工资 %d    性格 %s" % [emp.skill, emp.salary, emp.personality]
	stat_label.add_theme_font_size_override("font_size", 14)
	text_box.add_child(stat_label)

	row.add_child(text_box)

	var btn := Button.new()
	btn.text = "雇佣"
	btn.custom_minimum_size = Vector2(110, 48)
	btn.pressed.connect(_on_hire.bind(emp, row))
	row.add_child(btn)

	return row

func _make_employee_preview(role: String) -> Control:
	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(78, 78)

	var tex_rect := TextureRect.new()
	tex_rect.custom_minimum_size = Vector2(78, 78)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.texture = _load_role_preview(role)
	box.add_child(tex_rect)

	return box

func _load_role_preview(role: String) -> Texture2D:
	var frame_path := "res://assets/sprites/characters/%s/frames/idle/idle_1.png" % role
	if ResourceLoader.exists(frame_path):
		return load(frame_path)

	var sheet_path := "res://assets/sprites/characters/%s/idle.png" % role
	if ResourceLoader.exists(sheet_path):
		return load(sheet_path)

	return PixelBuilder.char_idle(role)

func _on_hire(emp: Employee, row: HBoxContainer):
	if GameManager.hire_employee(emp):
		row.queue_free()
		info_label.text = "已雇佣 %s，资金: %d" % [emp.name, GameManager.company.money]
		current_pool.erase(emp)
	else:
		info_label.text = "资金不足或工位已满"

func _on_close():
	hide()
