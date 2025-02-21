class_name UpdateTimerCommand
extends Command

var _timer: Timer
var _wait_time: float


func _init(timer: Timer) -> void:
	_timer = timer
	_wait_time = timer.time_left


func undo() -> void:
	_timer.wait_time = _wait_time
