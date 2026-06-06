extends Control

@onready var research_list: VBoxContainer = $Panel/VBox/ScrollContainer/ResearchList
@onready var btn_close: Button = $Panel/VBox/BtnClose
@onready var info_label: Label = $Panel/VBox/InfoLabel

func _ready():
	btn_close.pressed.connect(_on_close)
	GameManager.day_passed.connect(_on_day_passed)
	hide()

func show_tech_panel():
	_refresh_list()
	show()

func _refresh_list():
	for child in research_list.get_children():
		child.queue_free()

	var tt := GameManager.tech_tree
	for i in tt.researches.size():
		var r := tt.researches[i]
		var hbox := HBoxContainer.new()

		var label := Label.new()
		if r["done"]:
			label.text = "%s [已完成] %s" % [r["name"], r["desc"]]
		elif tt.current_index == i:
			label.text = "%s 研究中... (%.0f%%)" % [r["name"], tt.get_progress_percent()]
		else:
			label.text = "%s %s (%d天, %d元)" % [r["name"], r["desc"], r["days"], r["cost"]]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)

		if not r["done"] and tt.current_index < 0:
			var btn := Button.new()
			btn.text = "研究"
			btn.pressed.connect(_on_research.bind(i))
			if not GameManager.company.can_afford(r["cost"]):
				btn.disabled = true
			hbox.add_child(btn)
		elif tt.current_index == i:
			var progress_label := Label.new()
			progress_label.text = "%d/%d天" % [tt.research_progress, r["days"]]
			hbox.add_child(progress_label)

		research_list.add_child(hbox)

	info_label.text = "科技树 (资金: %d)" % GameManager.company.money

func _on_research(index: int):
	if GameManager.start_research(index):
		_refresh_list()

func _on_day_passed():
	if visible:
		_refresh_list()

func _on_close():
	hide()
