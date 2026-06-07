extends Control

@onready var log_list: VBoxContainer = $Panel/VBox/ScrollContainer/LogList
@onready var btn_close: Button = $Panel/VBox/BtnClose
@onready var info_label: Label = $Panel/VBox/InfoLabel

func _ready():
	btn_close.pressed.connect(_on_close)
	hide()

func show_log_panel():
	_refresh_list()
	show()

func _refresh_list():
	for child: Node in log_list.get_children():
		child.queue_free()

	var logs := EventSystem.event_log
	var start: int = maxi(0, logs.size() - 50)
	for i in range(start, logs.size()):
		var label := Label.new()
		label.text = logs[i]
		label.add_theme_font_size_override("font_size", 12)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		log_list.add_child(label)

	info_label.text = "事件日志 (共%d条)" % logs.size()

	# Scroll to bottom
	await get_tree().process_frame
	var scroll: ScrollContainer = $Panel/VBox/ScrollContainer
	if scroll:
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _on_close():
	hide()
