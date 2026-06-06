extends Resource
class_name Employee

@export var name: String = "未命名"
@export var role: String = "programmer"  # programmer, artist, designer, musician
@export var skill: int = 1
@export var salary: int = 1000
@export var morale: float = 1.0
@export var experience: int = 0

var hired_day: int = 0

func work() -> float:
	var base = skill * 10.0
	var morale_mult = lerpf(0.5, 1.2, morale)
	var exp_bonus = 1.0 + experience * 0.01
	return base * morale_mult * exp_bonus

func gain_experience(amount: int = 1):
	experience += amount
	if experience >= skill * 20 and skill < 10:
		skill += 1
		experience = 0

func get_role_name() -> String:
	match role:
		"programmer": return "程序员"
		"artist": return "美术"
		"designer": return "策划"
		"musician": return "音乐"
	return role
