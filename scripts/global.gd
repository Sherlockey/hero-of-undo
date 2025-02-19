extends Node

# Enemy
signal enemy_died(node: Node)
signal enemy_undied(node: Node)

# Exit Area
signal exit_area_entered()

var is_rewinding: bool = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("rewind"):
		is_rewinding = true
		get_tree().paused = false
	else:
		is_rewinding = false
