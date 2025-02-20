class_name MoveCommand
extends Command

var _character_body_2d: CharacterBody2D
var _before_position: Vector2
var _after_position: Vector2
var _rng_state: int


func _init(character_body_2d: CharacterBody2D, before_position: Vector2, data: Dictionary = {}) -> void:
	_character_body_2d = character_body_2d
	_before_position = before_position
	_data = data
	
	does_consume_process = true


func execute() -> void:
	_character_body_2d.global_position = _after_position


func undo() -> void:
	_character_body_2d.global_position = _before_position
