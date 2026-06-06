extends Control

@onready var name_input: LineEdit = $Panel/VBox/NameInput
@onready var genre_option: OptionButton = $Panel/VBox/GenreOption
@onready var theme_option: OptionButton = $Panel/VBox/ThemeOption
@onready var platform_option: OptionButton = $Panel/VBox/PlatformOption
@onready var btn_confirm: Button = $Panel/VBox/BtnConfirm
@onready var btn_cancel: Button = $Panel/VBox/BtnCancel
@onready var info_label: Label = $Panel/VBox/InfoLabel

func _ready():
	print("ProjectPanel _ready")
	btn_confirm.pressed.connect(_on_confirm)
	btn_cancel.pressed.connect(_on_cancel)
	hide()

func show_project_panel():
	if GameManager.current_project:
		info_label.text = "当前项目: %s\n进度: %.1f%%" % [
			GameManager.current_project.game_name,
			GameManager.current_project.get_total_progress()
		]
		btn_confirm.disabled = true
	else:
		info_label.text = "创建新项目"
		btn_confirm.disabled = false
		_setup_options()
	show()

func _setup_options():
	genre_option.clear()
	for genre in GameManager.genres:
		genre_option.add_item(genre)

	theme_option.clear()
	for t in GameManager.themes:
		theme_option.add_item(t)

	platform_option.clear()
	for platform in GameManager.platforms:
		platform_option.add_item(platform)

func _on_confirm():
	var game_name = name_input.text
	if game_name.is_empty():
		game_name = "游戏 #%d" % (GameManager.company.game_history.size() + 1)

	var genre = genre_option.get_item_text(genre_option.selected)
	var game_theme = theme_option.get_item_text(theme_option.selected)
	var platform = platform_option.get_item_text(platform_option.selected)

	if GameManager.start_project(game_name, genre, game_theme, platform):
		print("项目已创建: ", game_name)
		hide()
	else:
		info_label.text = "已有项目进行中！"

func _on_cancel():
	hide()
