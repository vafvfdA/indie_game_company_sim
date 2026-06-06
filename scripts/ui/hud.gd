extends Control

@onready var status_label: Label = $TopBar/HBox/StatusLabel
@onready var event_label: Label = $BottomBar/VBox/EventLabel
@onready var speed_label: Label = $TopBar/HBox/SpeedLabel
@onready var time_system: Node = $TimeSystem

@onready var btn_start: Button = $BottomBar/VBox/ButtonBar/BtnStart
@onready var btn_pause: Button = $BottomBar/VBox/ButtonBar/BtnPause
@onready var btn_hire: Button = $BottomBar/VBox/ButtonBar/BtnHire
@onready var btn_project: Button = $BottomBar/VBox/ButtonBar/BtnProject

@onready var btn_train: Button = $BottomBar/VBox/ExtraBar/BtnTrain
@onready var btn_tech: Button = $BottomBar/VBox/ExtraBar/BtnTech
@onready var btn_upgrade: Button = $BottomBar/VBox/ExtraBar/BtnUpgrade
@onready var btn_save: Button = $BottomBar/VBox/ExtraBar/BtnSave
@onready var btn_load: Button = $BottomBar/VBox/ExtraBar/BtnLoad

@onready var project_panel = $ProjectPanel
@onready var hire_panel = $HirePanel
@onready var result_panel = $ResultPanel
@onready var train_panel = $TrainPanel
@onready var tech_panel = $TechPanel

func _ready():
	# 半透明紧凑面板样式
	var top_style := StyleBoxFlat.new()
	top_style.bg_color = Color("1a1a2e", 0.85)
	top_style.border_color = Color("0f3460")
	top_style.set_border_width_all(0)
	top_style.set_corner_radius_all(0)
	top_style.set_content_margin_all(6)
	$TopBar.add_theme_stylebox_override("panel", top_style)

	var bottom_style := StyleBoxFlat.new()
	bottom_style.bg_color = Color("1a1a2e", 0.85)
	bottom_style.border_color = Color("0f3460")
	bottom_style.set_border_width_all(0)
	bottom_style.set_corner_radius_all(0)
	bottom_style.set_content_margin_all(6)
	$BottomBar.add_theme_stylebox_override("panel", bottom_style)

	# 连接信号
	GameManager.day_passed.connect(_update_ui)
	GameManager.month_passed.connect(_on_month_passed)
	GameManager.game_shipped.connect(_on_game_shipped)
	EventSystem.event_occurred.connect(_on_event)

	btn_start.pressed.connect(_on_start_pressed)
	btn_pause.pressed.connect(_on_pause_pressed)
	btn_hire.pressed.connect(_on_hire_pressed)
	btn_project.pressed.connect(_on_project_pressed)
	btn_train.pressed.connect(_on_train_pressed)
	btn_tech.pressed.connect(_on_tech_pressed)
	btn_upgrade.pressed.connect(_on_upgrade_pressed)
	btn_save.pressed.connect(_on_save_pressed)
	btn_load.pressed.connect(_on_load_pressed)

	btn_pause.disabled = true

	_update_ui()

func _on_start_pressed():
	if time_system:
		time_system.start()
		btn_start.disabled = true
		btn_pause.disabled = false
		event_label.text = "事件: 游戏开始运行！"

func _on_pause_pressed():
	if time_system:
		time_system.stop()
		btn_start.disabled = false
		btn_pause.disabled = true
		event_label.text = "事件: 已暂停"

func _on_hire_pressed():
	if hire_panel:
		hire_panel.show_hire_panel()

func _on_project_pressed():
	if project_panel:
		project_panel.show_project_panel()

func _on_train_pressed():
	if train_panel:
		train_panel.show_train_panel()

func _on_tech_pressed():
	if tech_panel:
		tech_panel.show_tech_panel()

func _on_upgrade_pressed():
	if not GameManager.company.can_upgrade():
		event_label.text = "办公室已满级！"
		return
	var cost = GameManager.company.get_upgrade_cost()
	if not GameManager.company.can_afford(cost):
		event_label.text = "资金不足！需要 %d 元" % cost
		return
	GameManager.upgrade_office()
	_update_ui()

func _on_save_pressed():
	GameManager.save_game(0)
	_update_ui()

func _on_load_pressed():
	if GameManager.load_game(0):
		_update_ui()
	else:
		event_label.text = "没有找到存档"

func _update_ui():
	if GameManager and GameManager.company:
		status_label.text = GameManager.get_status_text()
		if GameManager.current_project:
			status_label.text += GameManager.current_project.get_progress_detail()
		# Update upgrade button text
		if btn_upgrade:
			if GameManager.company.can_upgrade():
				btn_upgrade.text = "升级(%d)" % GameManager.company.get_upgrade_cost()
			else:
				btn_upgrade.text = "已满级"
		# Update rank display in title
		var title_label = $TopBar/HBox/Title
		if title_label and GameManager.company:
			title_label.text = GameManager.company.get_rank_title()

func _on_event(text: String):
	event_label.text = "事件: " + text

func _on_month_passed():
	_update_ui()

func _on_game_shipped(result: Dictionary):
	if time_system:
		time_system.stop()
	btn_start.disabled = false
	btn_pause.disabled = true
	if result_panel:
		result_panel.show_result(result)
