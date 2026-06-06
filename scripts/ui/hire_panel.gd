extends Control

@onready var employee_list: VBoxContainer = $Panel/VBox/ScrollContainer/EmployeeList
@onready var btn_refresh: Button = $Panel/VBox/BtnRefresh
@onready var btn_close: Button = $Panel/VBox/BtnClose
@onready var info_label: Label = $Panel/VBox/InfoLabel

var current_pool: Array = []

func _ready():
	print("HirePanel _ready")
	btn_refresh.pressed.connect(_refresh_pool)
	btn_close.pressed.connect(_on_close)
	hide()

func show_hire_panel():
	_refresh_pool()
	show()

func _refresh_pool():
	for child in employee_list.get_children():
		child.queue_free()

	current_pool = GameManager.get_employee_pool()

	for emp in current_pool:
		var hbox = HBoxContainer.new()

		var label = Label.new()
		label.text = "%s | %s | 技能:%d | 工资:%d" % [
			emp.name, emp.get_role_name(), emp.skill, emp.salary
		]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)

		var btn = Button.new()
		btn.text = "雇佣"
		btn.pressed.connect(_on_hire.bind(emp, hbox))
		hbox.add_child(btn)

		employee_list.add_child(hbox)

	info_label.text = "可招聘员工 (资金: %d)" % GameManager.company.money

func _on_hire(emp: Employee, hbox: HBoxContainer):
	if GameManager.hire_employee(emp):
		hbox.queue_free()
		info_label.text = "已雇佣 %s！资金: %d" % [emp.name, GameManager.company.money]
		current_pool.erase(emp)
	else:
		info_label.text = "资金不足！"

func _on_close():
	hide()
