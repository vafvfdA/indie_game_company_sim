extends RefCounted
class_name Company

var name: String = "独立工作室"
var money: int = 50000
var reputation: float = 0.0
var employees: Array = []
var game_history: Array = []
var office_level: int = 1

var _rent_table := [0, 500, 1500, 3000, 5000, 8000]

var max_desks: int:
	get: return 4 + (office_level - 1) * 4

func get_upgrade_cost() -> int:
	return office_level * 10000

func can_upgrade() -> bool:
	return office_level < 3

func upgrade_office() -> bool:
	if not can_upgrade():
		return false
	var cost = get_upgrade_cost()
	if not can_afford(cost):
		return false
	spend(cost)
	office_level += 1
	return true

func get_rank() -> int:
	if reputation >= 200: return 5
	if reputation >= 100: return 4
	if reputation >= 50: return 3
	if reputation >= 20: return 2
	return 1

func get_rank_title() -> String:
	match get_rank():
		1: return "无名工作室"
		2: return "小有名气"
		3: return "知名公司"
		4: return "业界巨头"
		5: return "传奇工作室"
	return "无名工作室"

func get_rent() -> int:
	if office_level < _rent_table.size():
		return _rent_table[office_level]
	return _rent_table[-1]

func can_afford(amount: int) -> bool:
	return money >= amount

func spend(amount: int) -> bool:
	if can_afford(amount):
		money -= amount
		return true
	return false

func earn(amount: int):
	money += amount

func pay_salaries() -> int:
	var total = 0
	for emp in employees:
		total += emp.salary
		spend(emp.salary)
	return total

func get_monthly_salary() -> int:
	var total = 0
	for emp in employees:
		total += emp.salary
	return total

func hire(employee) -> bool:
	if can_afford(employee.salary):
		employees.append(employee)
		return true
	return false

func fire(employee):
	employees.erase(employee)

func get_employee_count() -> int:
	return employees.size()

func get_average_skill() -> float:
	if employees.is_empty():
		return 0.0
	var total = 0.0
	for emp in employees:
		total += emp.skill
	return total / employees.size()
