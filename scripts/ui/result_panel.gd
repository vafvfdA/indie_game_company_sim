extends Control

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var detail_label: Label = $Panel/VBox/DetailLabel
@onready var btn_close: Button = $Panel/VBox/BtnClose

func _ready():
	print("ResultPanel _ready")
	btn_close.pressed.connect(_on_close)
	hide()

func show_result(result: Dictionary):
	title_label.text = "《%s》发售结果" % result["name"]

	var text = "类型: %s | 题材: %s | 平台: %s\n\n" % [
		result["genre"], result["theme"], result["platform"]
	]
	text += "综合评分: %.1f (%s)\n\n" % [result["score"], result["grade"]]
	var q: Dictionary = result["quality"]
	text += "趣味性: %.1f\n" % q["fun"]
	text += "画面: %.1f\n" % q["graphics"]
	text += "音效: %.1f\n" % q["audio"]
	text += "技术: %.1f\n\n" % q["tech"]
	text += "销量: %d 份\n" % result["copies_sold"]
	text += "收入: %d 元\n" % result["revenue"]

	detail_label.text = text
	show()

func _on_close():
	hide()
