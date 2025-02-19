extends Node

signal enemy_died(node: Node)
signal enemy_undied(node: Node)

var is_rewinding: bool = false


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("rewind"):
		is_rewinding = true
		Engine.time_scale = 1.0
	else:
		is_rewinding = false
