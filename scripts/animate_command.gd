class_name AnimateCommand
extends Command

var _animated_sprite_2d: AnimatedSprite2D
var _animation_name: String


func _init(animated_sprite_2d: AnimatedSprite2D, animation_name: String, does_await: bool = false) -> void:
	_animated_sprite_2d = animated_sprite_2d
	_animation_name = animation_name
	_does_await = does_await


func execute() -> void:
	_animated_sprite_2d.play(_animation_name)


func undo() -> void:
	_animated_sprite_2d.play_backwards(_animation_name)
	await _animated_sprite_2d.animation_finished
	finished.emit()
