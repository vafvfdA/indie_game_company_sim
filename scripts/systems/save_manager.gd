class_name SaveManager
extends RefCounted

static func get_save_info(slot: int) -> Dictionary:
	var path := "user://save_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var json := file.get_as_text()
	file.close()
	var data = JSON.parse_string(json)
	if data == null:
		return {}
	return data

static func has_save(slot: int) -> bool:
	return FileAccess.file_exists("user://save_%d.json" % slot)

static func delete_save(slot: int):
	var path := "user://save_%d.json" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

static func get_save_summary(slot: int) -> String:
	var data = get_save_info(slot)
	if data.is_empty():
		return "空存档"
	var c = data.get("company", {})
	var year = data.get("current_year", 1)
	var month = data.get("current_month", 1)
	var day = data.get("current_day", 1)
	return "%s | 资金:%d | %d年%d月%d日" % [
		c.get("name", "?"), c.get("money", 0), year, month, day
	]
