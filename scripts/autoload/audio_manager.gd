extends Node

var _player: AudioStreamPlayer
var _enabled: bool = true

func _ready():
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)

func play(sound_type: String):
	if not _enabled:
		return
	var stream := _generate_tone(sound_type)
	if stream:
		_player.stream = stream
		_player.play()

func _generate_tone(_sound_type: String) -> AudioStreamGenerator:
	# Use a simple beep approach with AudioStreamGenerator
	# For now, use a placeholder - actual tones require AudioStreamWAV
	return null

func set_enabled(enabled: bool):
	_enabled = enabled

# Convenience methods
func play_click():
	play("click")

func play_hire():
	play("hire")

func play_fire():
	play("fire")

func play_upgrade():
	play("upgrade")

func play_money():
	play("money")

func play_event():
	play("event")

func play_game_over():
	play("game_over")
