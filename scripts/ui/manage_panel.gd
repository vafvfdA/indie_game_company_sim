extends Control

@onready var employee_list: VBoxContainer = $Panel/VBox/ScrollContainer/EmployeeList
@onready var btn_close: Button = $Panel/VBox/BtnClose
@onready var info_label: Label = $Panel/VBox/InfoLabel

var _confirm_dialog: Control

func _ready():
	btn_close.pressed.connect(_on_close)
	hide()

func setup_confirm_dialog(dialog: Control):
	_confirm_dialog = dialog

func show_manage_panel():
	_refresh_list()
	show()

func _refresh_list():
	for child: Node in employee_list.get_children():
		child.queue_free()

	for emp: Employee in GameManager.company.employees:
		var hbox := HBoxContainer.new()

		var label := Label.new()
		label.text = "%s | %s | 技能:%d | 士气:%.0f%% | 工资:%d | %s" % [
			emp.name, emp.get_role_name(), emp.skill, emp.morale * 100, emp.salary, emp.personality
		]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)

		var btn_detail := Button.new()
		btn_detail.text = "详情"
		btn_detail.pressed.connect(_on_detail.bind(emp))
		hbox.add_child(btn_detail)

		var btn_fire := Button.new()
		btn_fire.text = "解雇"
		btn_fire.pressed.connect(_on_fire.bind(emp))
		hbox.add_child(btn_fire)

		employee_list.add_child(hbox)

	info_label.text = "员工管理 (共%d人)" % GameManager.company.get_employee_count()

func _on_detail(emp: Employee):
	# Show detail in info_label
	var days_worked = GameManager.current_day - emp.hired_day
	if days_worked < 0:
		days_worked = 0
	var exp_needed = emp.skill * 20
	info_label.text = "%s [%s]\n技能:%d | 经验:%d/%d | 士气:%.0f%%\n工资:%d/月 | 性格:%s (%s)\n入职天数:%d" % [
		emp.name, emp.get_role_name(), emp.skill, emp.experience, exp_needed,
		emp.morale * 100, emp.salary, emp.personality, emp.get_personality_desc(), days_worked
	]

func _on_fire(emp: Employee):
	if _confirm_dialog:
		var severance = emp.salary
		_confirm_dialog.show_dialog(
			"解雇员工",
			"确定要解雇 %s 吗？\n遣散费: %d 元\n其他员工士气将下降。" % [emp.name, severance],
			"解雇"
		)
		_confirm_dialog.confirmed.connect(_do_fire.bind(emp), CONNECT_ONE_SHOT)
	else:
		_do_fire(emp)

func _do_fire(emp: Employee):
	var severance = emp.salary
	if GameManager.company.can_afford(severance):
		GameManager.company.spend(severance)
		EventSystem.emit_event("支付遣散费 %d 元" % severance)
	GameManager.fire_employee(emp)
	# Morale hit to remaining employees
	for other: Employee in GameManager.company.employees:
		other.modify_morale(-0.1)
	EventSystem.emit_event("解雇了 %s" % emp.name)
	_refresh_list()

func _on_close():
	hide()
