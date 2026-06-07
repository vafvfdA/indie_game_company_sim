extends RefCounted
class_name TechTree

var researches: Array[Dictionary] = [
	{"name": "引擎优化", "desc": "程序开发速度+20%", "cost": 5000, "days": 15, "done": false, "effect": "program", "value": 0.2},
	{"name": "美术风格", "desc": "美术质量+20%", "cost": 5000, "days": 15, "done": false, "effect": "art", "value": 0.2},
	{"name": "音效技术", "desc": "音效质量+20%", "cost": 4000, "days": 10, "done": false, "effect": "audio", "value": 0.2},
	{"name": "测试框架", "desc": "Bug减少50%", "cost": 6000, "days": 20, "done": false, "effect": "bug_reduce", "value": 0.5},
	{"name": "市场分析", "desc": "兼容性加成+0.2", "cost": 8000, "days": 20, "done": false, "effect": "compat", "value": 0.2},
]

var current_index: int = -1
var research_progress: int = 0

func get_bonus(effect_name: String) -> float:
	var total := 0.0
	for r: Dictionary in researches:
		if r["done"] and r["effect"] == effect_name:
			total += r["value"]
	return total

func start_research(index: int) -> bool:
	if current_index >= 0:
		return false
	if index < 0 or index >= researches.size():
		return false
	if researches[index]["done"]:
		return false
	current_index = index
	research_progress = 0
	return true

func advance_day() -> Dictionary:
	if current_index < 0:
		return {}
	research_progress += 1
	var r: Dictionary = researches[current_index]
	if research_progress >= r["days"]:
		r["done"] = true
		var completed := current_index
		current_index = -1
		research_progress = 0
		return {"completed": true, "name": r["name"], "index": completed}
	return {"completed": false, "progress": research_progress, "total": r["days"]}

func is_researching() -> bool:
	return current_index >= 0

func get_progress_percent() -> float:
	if current_index < 0:
		return 0.0
	return float(research_progress) / researches[current_index]["days"] * 100.0

func serialize() -> Dictionary:
	return {
		"researches": researches.duplicate(true),
		"current_index": current_index,
		"research_progress": research_progress,
	}

func deserialize(data: Dictionary):
	var raw: Array = data.get("researches", [])
	if raw.size() > 0:
		researches.clear()
		for item: Dictionary in raw:
			researches.append(item as Dictionary)
	current_index = data.get("current_index", -1)
	research_progress = data.get("research_progress", 0)
