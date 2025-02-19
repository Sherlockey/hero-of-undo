class_name TakeDamageCommand
extends Command

var _character_body_2d: CharacterBody2D
var _damage: int


func _init(character_body_2d: CharacterBody2D, damage: int) -> void:
	_character_body_2d = character_body_2d
	_damage = damage


func undo() -> void:
	if "health" in _character_body_2d:
		_character_body_2d.health += _damage
