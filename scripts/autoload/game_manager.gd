extends Node

signal day_passed
signal month_passed
signal game_shipped(result)
signal money_changed(new_amount)
signal not_enough_money
signal employee_hired(employee)
signal employee_fired(employee)

var company: Company
var current_project: GameProject = null
var current_day: int = 1
var current_month: int = 1
var current_year: int = 1
var is_paused: bool = false
var game_speed: float = 1.0

var genres: Array = ["RPG", "SLG", "ACT", "AVG", "STG", "PUZ", "SIM", "SPG"]
var themes: Array = ["奇幻", "科幻", "都市", "历史", "恐怖", "日常", "武侠", "末日"]
var platforms: Array = ["PC", "主机", "手机"]

var compatibility: Dictionary = {
	"RPG": {"奇幻": 1.2, "科幻": 1.1, "武侠": 1.3, "末日": 0.9},
	"SLG": {"历史": 1.3, "科幻": 1.1, "都市": 1.0},
	"ACT": {"武侠": 1.2, "科幻": 1.1, "末日": 1.1},
	"AVG": {"恐怖": 1.3, "日常": 1.1, "都市": 1.0},
	"STG": {"科幻": 1.2, "末日": 1.1},
	"PUZ": {"日常": 1.2, "奇幻": 1.0},
	"SIM": {"都市": 1.3, "日常": 1.1, "农场": 1.2},
	"SPG": {"都市": 1.1, "历史": 1.0},
}

func _ready():
	print("GameManager _ready")
	company = Company.new()
	print("Company 创建完成, 资金: ", company.money)

func start_project(game_name: String, genre: String, theme: String, platform: String) -> bool:
	if current_project != null:
		return false

	current_project = GameProject.new()
	current_project.game_name = game_name
	current_project.genre = genre
	current_project.theme = theme
	current_project.target_platform = platform

	var emp_count = company.get_employee_count()
	var scale = clampf(1.0 + (emp_count - 1) * 0.3, 1.0, 3.0)
	for key in current_project.required:
		current_project.required[key] *= scale

	print("项目创建: ", game_name, " ", genre, "/", theme, "/", platform)
	return true

func advance_day():
	current_day += 1

	if current_day > 30:
		current_day = 1
		current_month += 1
		month_passed.emit()

		var salaries = company.pay_salaries()
		if salaries > 0:
			EventSystem.emit_event("发工资: 支出 %d 元" % salaries)

		if current_month > 12:
			current_month = 1
			current_year += 1

	if current_project:
		current_project.develop(company.employees)
		if current_project.is_finished:
			_ship_game()

	day_passed.emit()

func _ship_game():
	var result = _calculate_sales(current_project)
	company.earn(result["revenue"])
	company.game_history.append(result)
	company.reputation += result["score"] - 5.0
	company.reputation = clampf(company.reputation, -100, 100)
	money_changed.emit(company.money)
	game_shipped.emit(result)
	current_project = null

func _calculate_sales(project: GameProject) -> Dictionary:
	var base_score = project.quality["overall"]

	var compat_mult = 1.0
	if project.genre in compatibility:
		if project.theme in compatibility[project.genre]:
			compat_mult = compatibility[project.genre][project.theme]

	var final_score = clampf(base_score * compat_mult, 0, 100)

	var grade = "S"
	if final_score < 90: grade = "A"
	if final_score < 75: grade = "B"
	if final_score < 60: grade = "C"
	if final_score < 40: grade = "D"
	if final_score < 20: grade = "F"

	var base_sales = final_score * final_score * 10
	var rep_bonus = 1.0 + company.reputation * 0.01
	var platform_mult = 1.0
	match project.target_platform:
		"PC": platform_mult = 1.0
		"主机": platform_mult = 1.5
		"手机": platform_mult = 2.0

	var total_sales = int(base_sales * rep_bonus * platform_mult)
	var revenue = total_sales * 10

	return {
		"name": project.game_name,
		"genre": project.genre,
		"theme": project.theme,
		"platform": project.target_platform,
		"score": final_score,
		"grade": grade,
		"quality": project.quality.duplicate(),
		"copies_sold": total_sales,
		"revenue": revenue,
		"day": current_day,
		"month": current_month,
		"year": current_year,
	}

func get_employee_pool() -> Array:
	var pool: Array = []
	var role_list = ["programmer", "artist", "designer", "musician"]
	var name_pool = ["小明", "小红", "小刚", "小丽", "大伟", "小芳", "阿强", "小美",
		"老张", "小李", "阿杰", "小雪", "大卫", "小琳", "阿龙", "小云"]

	for i in 6:
		var emp = Employee.new()
		emp.name = name_pool[randi() % name_pool.size()]
		emp.role = role_list[randi() % role_list.size()]
		emp.skill = randi_range(1, 5)
		emp.salary = 500 + emp.skill * 500 + randi_range(0, 500)
		pool.append(emp)

	return pool

func hire_employee(employee) -> bool:
	if company.hire(employee):
		employee.hired_day = current_day
		money_changed.emit(company.money)
		employee_hired.emit(employee)
		print("雇佣了: ", employee.name, " ", employee.get_role_name())
		return true
	not_enough_money.emit()
	return false

func fire_employee(employee):
	company.fire(employee)
	employee_fired.emit(employee)

func get_status_text() -> String:
	var text = "=== %s ===\n" % company.name
	text += "资金: %d 元\n" % company.money
	text += "声望: %.1f\n" % company.reputation
	text += "日期: %d年%d月%d日\n" % [current_year, current_month, current_day]
	text += "员工: %d人 | 月工资: %d\n" % [company.get_employee_count(), company.get_monthly_salary()]
	if current_project:
		text += "\n当前项目: %s\n" % current_project.game_name
		text += "进度: %.1f%%\n" % current_project.get_total_progress()
	return text
