extends Node

# Enemy
signal enemy_died(node: Node)
signal enemy_undied(node: Node)

# Exit Area
signal exit_area_entered()

var is_rewinding: bool = false
var audio_bus_layout: AudioBusLayout = preload("res://resources/new_audio_bus_layout.tres")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = PROCESS_MODE_ALWAYS
	AudioServer.set_bus_layout(audio_bus_layout)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("rewind"):
		is_rewinding = true
		get_tree().paused = false
		AudioServer.set_bus_effect_enabled(0, 0, true)
		AudioServer.set_bus_effect_enabled(0, 1, true)
		AudioServer.set_bus_effect_enabled(0, 2, true)
	else:
		is_rewinding = false
		AudioServer.set_bus_effect_enabled(0, 0, false)
		AudioServer.set_bus_effect_enabled(0, 1, false)
		AudioServer.set_bus_effect_enabled(0, 2, false)
