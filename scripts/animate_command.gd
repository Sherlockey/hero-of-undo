class_name AnimateCommand
extends Command

var _animated_sprite_2d: AnimatedSprite2D
var _animation_name: String


func _init(animated_sprite_2d: AnimatedSprite2D, animation_name: String) -> void:
	_animated_sprite_2d = animated_sprite_2d
	_animation_name = animation_name


func execute() -> void:
	_animated_sprite_2d.play(_animation_name)


func undo() -> void:
	_animated_sprite_2d.play_backwards(_animation_name)
