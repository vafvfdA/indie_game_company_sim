extends Control

@onready var title_label: Label = $Panel/VBox/Title
@onready var stats_label: Label = $Panel/VBox/StatsLabel
@onready var btn_restart: Button = $Panel/VBox/BtnRestart

func _ready():
	btn_restart.pressed.connect(_on_restart)
	hide()

func show_game_over(reason: String):
	title_label.text = "游戏结束"
	var stats_text: String = "原因: %s\n\n" % reason
	stats_text += "=== 最终统计 ===\n"
	stats_text += "运营天数: %d 天\n" % _get_total_days()
	stats_text += "发布游戏: %d 款\n" % GameManager.company.game_history.size()
	stats_text += "最高声望: %.0f\n" % GameManager.company.reputation
	stats_text += "公司等级: %s\n" % GameManager.company.get_rank_title()
	stats_text += "办公室等级: Lv%d\n" % GameManager.company.office_level

	if GameManager.company.game_history.size() > 0:
		var best_score: float = 0.0
		for game: Dictionary in GameManager.company.game_history:
			var score: float = game.get("score", 0.0)
			if score > best_score:
				best_score = score
		stats_text += "最高游戏评分: %.1f\n" % best_score

	stats_label.text = stats_text
	show()

func _get_total_days() -> int:
	return (GameManager.current_year - 1) * 360 + (GameManager.current_month - 1) * 30 + GameManager.current_day

func _on_restart():
	hide()
	GameManager.current_day = 1
	GameManager.current_month = 1
	GameManager.current_year = 1
	GameManager.current_project = null
	GameManager.is_paused = false
	GameManager.game_speed = 1.0
	GameManager._game_over_triggered = false
	GameManager.company = Company.new()
	GameManager.tech_tree = load("res://scripts/models/tech_tree.gd").new()
	GameManager.rival_companies = RivalCompany.create_default_rivals()
	GameManager.day_passed.emit()
	GameManager.money_changed.emit(GameManager.company.money)
	EventSystem.event_log.clear()
	EventSystem.emit_event("新公司成立！加油！")
