extends Control

var _container: VBoxContainer
var _notifications: Array[Control] = []

const MAX_VISIBLE := 5
const FADE_DURATION := 0.5
const DISPLAY_DURATION := 3.0

func _ready():
	_container = VBoxContainer.new()
	_container.alignment = BoxContainer.ALIGNMENT_END
	_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_container.position = Vector2(-260, 10)
	_container.size = Vector2(250, 0)
	_container.z_index = 100
	add_child(_container)

	EventSystem.event_occurred.connect(_on_event)

func _on_event(text: String):
	var type := "info"
	if "损失" in text or "下降" in text or "低落" in text or "攻击" in text or "纠纷" in text:
		type = "warning"
	elif "提升" in text or "完成" in text or "获得" in text or "补贴" in text or "爆发" in text or "大会" in text:
		type = "success"
	show_notification(text, type)

func show_notification(text: String, type: String = "info"):
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	match type:
		"warning":
			style.bg_color = Color("5a1a1a", 0.9)
			style.border_color = Color("e94560")
		"success":
			style.bg_color = Color("1a3a1a", 0.9)
			style.border_color = Color("45e960")
		_:
			style.bg_color = Color("1a1a3e", 0.9)
			style.border_color = Color("4560e9")
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(label)

	_container.add_child(panel)
	_notifications.append(panel)

	# Remove old if too many
	while _notifications.size() > MAX_VISIBLE:
		var old: Control = _notifications.pop_front()
		if is_instance_valid(old):
			old.queue_free()

	# Fade out after delay
	var tween: Tween = create_tween()
	tween.tween_interval(DISPLAY_DURATION)
	tween.tween_property(panel, "modulate:a", 0.0, FADE_DURATION)
	tween.finished.connect(func():
		_notifications.erase(panel)
		if is_instance_valid(panel):
			panel.queue_free()
	)
