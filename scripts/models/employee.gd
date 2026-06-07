extends Resource
class_name Employee

@export var name: String = "未命名"
@export var role: String = "programmer"  # programmer, artist, designer, musician
@export var skill: int = 1
@export var salary: int = 1000
@export var morale: float = 1.0
@export var experience: int = 0
@export var personality: String = ""

var hired_day: int = 0

const PERSONALITIES := ["勤奋", "懒散", "乐观", "悲观", "天才", "社交"]

static func random_personality() -> String:
	return PERSONALITIES[randi() % PERSONALITIES.size()]

func work() -> float:
	var base = skill * 10.0
	var morale_mult = lerpf(0.5, 1.2, morale)
	var exp_bonus = 1.0 + experience * 0.01
	var result = base * morale_mult * exp_bonus
	match personality:
		"勤奋": result *= 1.2
		"懒散": result *= 0.85
	return result

func gain_experience(amount: int = 1):
	if personality == "天才":
		amount = int(amount * 1.5)
	experience += amount
	if experience >= skill * 20 and skill < 10:
		skill += 1
		experience = 0

func get_personality_desc() -> String:
	match personality:
		"勤奋": return "工作效率+20%"
		"懒散": return "工作效率-15%"
		"乐观": return "士气下降减半"
		"悲观": return "士气下降翻倍"
		"天才": return "经验获取+50%"
		"社交": return "同事士气提升"
	return "无"

func modify_morale(amount: float):
	if amount < 0:
		match personality:
			"乐观": amount *= 0.5
			"悲观": amount *= 2.0
	morale = clampf(morale + amount, 0, 1)

func get_role_name() -> String:
	match role:
		"programmer": return "程序员"
		"artist": return "美术"
		"designer": return "策划"
		"musician": return "音乐"
	return role
