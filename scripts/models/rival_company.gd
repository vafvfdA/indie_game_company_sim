extends RefCounted
class_name RivalCompany

var name: String
var reputation: float
var money: int

func _init(n: String, rep: float, m: int):
	name = n
	reputation = rep
	money = m

func monthly_update():
	# Simulate releasing a game
	var score = randf_range(20, 80)
	var revenue = int(score * score * randf_range(5, 15))
	money += revenue
	reputation += score * 0.05 - 2.0
	reputation = clampf(reputation, 0, 300)
	money = maxi(money, 0)

	# Random events
	if randf() < 0.1:
		reputation += randf_range(-10, 15)
	if randf() < 0.05:
		money -= randi_range(1000, 5000)
		money = maxi(money, 0)

static func create_default_rivals() -> Array:
	return [
		RivalCompany.new("星辰游戏", 30, 80000),
		RivalCompany.new("月光工作室", 15, 60000),
		RivalCompany.new("雷霆互动", 50, 120000),
	]
