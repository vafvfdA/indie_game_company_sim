extends Control

signal confirmed
signal cancelled

@onready var title_label: Label = $Panel/VBox/Title
@onready var desc_label: Label = $Panel/VBox/DescLabel
@onready var btn_confirm: Button = $Panel/VBox/ButtonBar/BtnConfirm
@onready var btn_cancel: Button = $Panel/VBox/ButtonBar/BtnCancel

func _ready():
	btn_confirm.pressed.connect(_on_confirm)
	btn_cancel.pressed.connect(_on_cancel)
	hide()

func show_dialog(title: String, description: String, confirm_text: String = "确认"):
	title_label.text = title
	desc_label.text = description
	btn_confirm.text = confirm_text
	show()

func _on_confirm():
	hide()
	confirmed.emit()

func _on_cancel():
	hide()
	cancelled.emit()
