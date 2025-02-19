class_name DieCommand
extends Command

var _character_body_2d: CharacterBody2D


func _init(character_body_2d: CharacterBody2D) -> void:
	_character_body_2d = character_body_2d


func undo() -> void:
	if "is_dead" in _character_body_2d:
		_character_body_2d.is_dead = false
