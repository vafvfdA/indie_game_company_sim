extends Control

@onready var employee_list: VBoxContainer = $Panel/VBox/ScrollContainer/EmployeeList
@onready var btn_close: Button = $Panel/VBox/BtnClose
@onready var info_label: Label = $Panel/VBox/InfoLabel

func _ready():
	btn_close.pressed.connect(_on_close)
	hide()

func show_train_panel():
	_refresh_list()
	show()

func _refresh_list():
	for child in employee_list.get_children():
		child.queue_free()

	for emp in GameManager.company.employees:
		var hbox := HBoxContainer.new()

		var label := Label.new()
		label.text = "%s | %s | 技能:%d | 士气:%.0f%%" % [
			emp.name, emp.get_role_name(), emp.skill, emp.morale * 100
		]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)

		var cost := GameManager.get_train_cost(emp)
		var btn := Button.new()
		btn.text = "培训 (%d元)" % cost
		if not GameManager.company.can_afford(cost):
			btn.disabled = true
		btn.pressed.connect(_on_train.bind(emp, hbox, btn))
		hbox.add_child(btn)

		employee_list.add_child(hbox)

	info_label.text = "员工培训 (资金: %d)" % GameManager.company.money

func _on_train(emp: Employee, _hbox: HBoxContainer, _btn: Button):
	if GameManager.train_employee(emp):
		info_label.text = "培训成功！%s 技能提升" % emp.name
		_refresh_list()
	else:
		info_label.text = "资金不足！"

func _on_close():
	hide()
