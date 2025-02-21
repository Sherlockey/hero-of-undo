class_name MoveCommand
extends Command

var _node2d: Node2D
var _before_position: Vector2
var _after_position: Vector2
var _rng_state: int


func _init(node2d: Node2D, before_position: Vector2, data: Dictionary = {}) -> void:
	_node2d = node2d
	_before_position = before_position
	_data = data
	
	does_consume_process = true


func undo() -> void:
	_node2d.global_position = _before_position
