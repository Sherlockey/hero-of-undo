class_name MoveCommand
extends Command

var _character_body_2d: CharacterBody2D
var _velocity: Vector2


func _init(character_body_2d: CharacterBody2D, velocity: Vector2) -> void:
	_character_body_2d = character_body_2d
	_velocity = velocity
	
	does_consume_process = true


func execute() -> void:
	_character_body_2d.velocity = _velocity
	_character_body_2d.move_and_slide()


func undo() -> void:
	_character_body_2d.velocity = -_velocity
	_character_body_2d.move_and_slide()
