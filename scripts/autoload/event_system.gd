extends Node

signal event_occurred(event_text)

var event_log: Array[String] = []
var max_log_size: int = 50

# 随机事件池
var random_events: Array = [
	{"text": "员工加班导致士气下降", "chance": 0.05, "effect": "_event_morale_down"},
	{"text": "团队聚餐，士气提升！", "chance": 0.03, "effect": "_event_morale_up"},
	{"text": "收到玩家感谢信，声望+5", "chance": 0.02, "effect": "_event_reputation_up"},
	{"text": "服务器故障，损失 2000 元", "chance": 0.02, "effect": "_event_money_loss"},
	{"text": "获得媒体关注，声望+10", "chance": 0.01, "effect": "_event_reputation_up_big"},
]

func emit_event(text: String):
	event_log.append(text)
	if event_log.size() > max_log_size:
		event_log.pop_front()
	event_occurred.emit(text)

func check_random_events():
	for event in random_events:
		if randf() < event["chance"]:
			emit_event(event["text"])
			call(event["effect"])

func _event_morale_down():
	for emp in GameManager.company.employees:
		emp.morale = clampf(emp.morale - 0.1, 0, 1)

func _event_morale_up():
	for emp in GameManager.company.employees:
		emp.morale = clampf(emp.morale + 0.15, 0, 1)

func _event_reputation_up():
	GameManager.company.reputation += 5

func _event_reputation_up_big():
	GameManager.company.reputation += 10

func _event_money_loss():
	GameManager.company.spend(2000)

func get_recent_logs(count: int = 10) -> String:
	var lines: PackedStringArray = []
	var start = max(0, event_log.size() - count)
	for i in range(start, event_log.size()):
		lines.append(event_log[i])
	return "\n".join(lines)
