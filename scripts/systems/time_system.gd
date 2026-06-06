extends Node

@export var tick_interval: float = 1.0

var timer: Timer
var is_running: bool = false

func _ready():
	print("TimeSystem _ready")
	timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(_on_tick)
	add_child(timer)
	print("Timer 创建完成")

func start():
	print("TimeSystem start 被调用")
	is_running = true
	timer.wait_time = tick_interval / GameManager.game_speed
	timer.start()
	print("Timer 已启动, 间隔: ", timer.wait_time)

func stop():
	is_running = false
	timer.stop()

func set_speed(speed: float):
	GameManager.game_speed = speed
	if is_running:
		timer.wait_time = tick_interval / speed

func _on_tick():
	GameManager.advance_day()
	EventSystem.check_random_events()
