extends Control

@onready var status_label: Label = $VBox/StatusLabel
@onready var event_label: Label = $VBox/EventLabel
@onready var speed_label: Label = $VBox/TopBar/SpeedLabel
@onready var time_system: Node = $TimeSystem

@onready var btn_start: Button = $VBox/ButtonBar/BtnStart
@onready var btn_pause: Button = $VBox/ButtonBar/BtnPause
@onready var btn_hire: Button = $VBox/ButtonBar/BtnHire
@onready var btn_project: Button = $VBox/ButtonBar/BtnProject

@onready var project_panel = $ProjectPanel
@onready var hire_panel = $HirePanel
@onready var result_panel = $ResultPanel

func _ready():
	print("HUD _ready 开始")
	print("GameManager: ", GameManager)
	print("GameManager.company: ", GameManager.company)

	# 连接信号
	GameManager.day_passed.connect(_update_ui)
	GameManager.month_passed.connect(_on_month_passed)
	GameManager.game_shipped.connect(_on_game_shipped)
	EventSystem.event_occurred.connect(_on_event)

	btn_start.pressed.connect(_on_start_pressed)
	btn_pause.pressed.connect(_on_pause_pressed)
	btn_hire.pressed.connect(_on_hire_pressed)
	btn_project.pressed.connect(_on_project_pressed)

	btn_pause.disabled = true

	print("HUD 信号连接完成")
	_update_ui()
	print("HUD _ready 结束")

func _on_start_pressed():
	print("点击了开始")
	if time_system:
		time_system.start()
		btn_start.disabled = true
		btn_pause.disabled = false
		event_label.text = "事件: 游戏开始运行！"

func _on_pause_pressed():
	print("点击了暂停")
	if time_system:
		time_system.stop()
		btn_start.disabled = false
		btn_pause.disabled = true
		event_label.text = "事件: 已暂停"

func _on_hire_pressed():
	print("点击了招聘")
	if hire_panel:
		hire_panel.show_hire_panel()

func _on_project_pressed():
	print("点击了项目")
	if project_panel:
		project_panel.show_project_panel()

func _update_ui():
	if GameManager and GameManager.company:
		status_label.text = GameManager.get_status_text()
		if GameManager.current_project:
			status_label.text += GameManager.current_project.get_progress_detail()

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
