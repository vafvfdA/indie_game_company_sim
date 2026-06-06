extends RefCounted
class_name Company

var name: String = "独立工作室"
var money: int = 50000
var reputation: float = 0.0
var employees: Array = []
var game_history: Array = []
var office_level: int = 1

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
