extends Node

signal enemy_died(node: Node)

var is_rewinding: bool = false


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("rewind"):
		is_rewinding = true
	else:
		is_rewinding = false
