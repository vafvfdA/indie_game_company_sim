extends RefCounted
class_name GameProject

var game_name: String = "未命名游戏"
var genre: String = "RPG"
var theme: String = "奇幻"
var target_platform: String = "PC"

var progress: Dictionary = {
	"design": 0.0,
	"program": 0.0,
	"art": 0.0,
	"audio": 0.0,
}

var required: Dictionary = {
	"design": 1000.0,
	"program": 1000.0,
	"art": 1000.0,
	"audio": 1000.0,
}

var quality: Dictionary = {}
var is_finished: bool = false
var bug_count: int = 0

func develop(employees: Array) -> void:
	if is_finished:
		return

	# Tech tree bonuses
	var tech_bonuses := {}
	if GameManager and GameManager.tech_tree:
		for effect in ["program", "art", "audio", "design"]:
			tech_bonuses[effect] = GameManager.tech_tree.get_bonus(effect)
		var bug_reduce = GameManager.tech_tree.get_bonus("bug_reduce")

	for emp in employees:
		var contribution = emp.work()
		# Apply tech bonus
		match emp.role:
			"programmer":
				contribution *= (1.0 + tech_bonuses.get("program", 0.0))
				progress["program"] += contribution
				var bug_chance := 0.1 * (1.0 - GameManager.tech_tree.get_bonus("bug_reduce")) if GameManager and GameManager.tech_tree else 0.1
				if randf() < bug_chance:
					bug_count += 1
			"artist":
				contribution *= (1.0 + tech_bonuses.get("art", 0.0))
				progress["art"] += contribution
			"designer":
				contribution *= (1.0 + tech_bonuses.get("design", 0.0))
				progress["design"] += contribution
			"musician":
				contribution *= (1.0 + tech_bonuses.get("audio", 0.0))
				progress["audio"] += contribution
		emp.gain_experience(1)

	if _all_done():
		_calculate_quality()
		is_finished = true

func _all_done() -> bool:
	for key in progress:
		if progress[key] < required[key]:
			return false
	return true

func _calculate_quality() -> void:
	var design_score = (progress["design"] / required["design"]) * 100.0
	var program_score = (progress["program"] / required["program"]) * 100.0
	var art_score = (progress["art"] / required["art"]) * 100.0
	var audio_score = (progress["audio"] / required["audio"]) * 100.0

	# Bug 降低技术分
	var bug_penalty = bug_count * 2.0

	quality = {
		"fun": design_score * 0.5 + program_score * 0.2 + randf() * 10,
		"graphics": art_score,
		"audio": audio_score,
		"tech": clampf(program_score - bug_penalty, 0, 100),
	}
	quality["overall"] = (quality["fun"] + quality["graphics"] + quality["audio"] + quality["tech"]) / 4.0

func get_total_progress() -> float:
	var total = 0.0
	var max_total = 0.0
	for key in progress:
		total += progress[key]
		max_total += required[key]
	return total / max_total * 100.0

func get_progress_detail() -> String:
	var lines: PackedStringArray = []
	lines.append("设计: %.0f/%.0f" % [progress["design"], required["design"]])
	lines.append("程序: %.0f/%.0f" % [progress["program"], required["program"]])
	lines.append("美术: %.0f/%.0f" % [progress["art"], required["art"]])
	lines.append("音效: %.0f/%.0f" % [progress["audio"], required["audio"]])
	if bug_count > 0:
		lines.append("Bug: %d" % bug_count)
	return "\n".join(lines)
