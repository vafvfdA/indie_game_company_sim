extends Node

signal day_passed
signal month_passed
signal game_shipped(result)
signal money_changed(new_amount)
signal not_enough_money
signal employee_hired(employee)
signal employee_fired(employee)
signal employee_trained(employee)
signal office_upgraded

var company: Company
var tech_tree: RefCounted
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
	tech_tree = load("res://scripts/models/tech_tree.gd").new()
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

	advance_research()

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
	compat_mult += tech_tree.get_bonus("compat")

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
	if company.get_employee_count() >= company.max_desks:
		EventSystem.emit_event("工位已满！请先升级办公室。")
		return false
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

# --- Training ---

func get_train_cost(employee) -> int:
	return employee.skill * 1000 + 500

func train_employee(employee) -> bool:
	var cost = get_train_cost(employee)
	if not company.can_afford(cost):
		not_enough_money.emit()
		return false
	company.spend(cost)
	employee.gain_experience(employee.skill * 10)
	employee.morale = clampf(employee.morale + 0.1, 0, 1)
	money_changed.emit(company.money)
	employee_trained.emit(employee)
	EventSystem.emit_event("培训了 %s，技能提升！" % employee.name)
	return true

# --- Office Upgrade ---

func upgrade_office() -> bool:
	if company.upgrade_office():
		money_changed.emit(company.money)
		office_upgraded.emit()
		EventSystem.emit_event("办公室升级到 Lv%d！" % company.office_level)
		return true
	return false

# --- Tech Tree ---

func start_research(index: int) -> bool:
	var cost = tech_tree.researches[index]["cost"]
	if not company.can_afford(cost):
		not_enough_money.emit()
		return false
	company.spend(cost)
	money_changed.emit(company.money)
	tech_tree.start_research(index)
	EventSystem.emit_event("开始研究: %s" % tech_tree.researches[index]["name"])
	return true

func advance_research():
	var result = tech_tree.advance_day()
	if result.get("completed"):
		EventSystem.emit_event("研究完成: %s！" % result["name"])

func get_status_text() -> String:
	var text = "=== %s ===\n" % company.name
	text += "资金: %d 元\n" % company.money
	text += "声望: %.1f\n" % company.reputation
	text += "日期: %d年%d月%d日\n" % [current_year, current_month, current_day]
	text += "员工: %d/%d人 | 月工资: %d\n" % [company.get_employee_count(), company.max_desks, company.get_monthly_salary()]
	text += "办公室: Lv%d\n" % company.office_level
	if tech_tree.is_researching():
		var r = tech_tree.researches[tech_tree.current_index]
		text += "研究: %s (%.0f%%)\n" % [r["name"], tech_tree.get_progress_percent()]
	if current_project:
		text += "\n当前项目: %s\n" % current_project.game_name
		text += "进度: %.1f%%\n" % current_project.get_total_progress()
	return text

# --- Save / Load ---

func save_game(slot: int = 0):
	var data := {
		"company": {
			"name": company.name,
			"money": company.money,
			"reputation": company.reputation,
			"office_level": company.office_level,
			"game_history": company.game_history,
			"employees": _serialize_employees(),
		},
		"tech_tree": tech_tree.serialize(),
		"current_day": current_day,
		"current_month": current_month,
		"current_year": current_year,
	}
	var json := JSON.stringify(data)
	var path := "user://save_%d.json" % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json)
	file.close()
	EventSystem.emit_event("游戏已保存到存档 %d" % (slot + 1))

func load_game(slot: int = 0) -> bool:
	var path := "user://save_%d.json" % slot
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	var json := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(json)
	if parsed == null:
		return false
	_apply_save_data(parsed)
	EventSystem.emit_event("已读取存档 %d" % (slot + 1))
	return true

func has_save(slot: int) -> bool:
	return FileAccess.file_exists("user://save_%d.json" % slot)

func _serialize_employees() -> Array:
	var arr := []
	for emp in company.employees:
		arr.append({
			"name": emp.name,
			"role": emp.role,
			"skill": emp.skill,
			"salary": emp.salary,
			"morale": emp.morale,
			"experience": emp.experience,
		})
	return arr

func _apply_save_data(data: Dictionary):
	company.name = data["company"].get("name", "独立工作室")
	company.money = data["company"].get("money", 50000)
	company.reputation = data["company"].get("reputation", 0)
	company.office_level = data["company"].get("office_level", 1)
	company.game_history = data["company"].get("game_history", [])
	company.employees.clear()

	for edata in data["company"].get("employees", []):
		var emp := Employee.new()
		emp.name = edata["name"]
		emp.role = edata["role"]
		emp.skill = edata["skill"]
		emp.salary = edata["salary"]
		emp.morale = edata["morale"]
		emp.experience = edata["experience"]
		company.employees.append(emp)

	tech_tree.deserialize(data.get("tech_tree", {}))
	current_day = data.get("current_day", 1)
	current_month = data.get("current_month", 1)
	current_year = data.get("current_year", 1)
	current_project = null

	day_passed.emit()
	office_upgraded.emit()
	for emp in company.employees:
		employee_hired.emit(emp)
