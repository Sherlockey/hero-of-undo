class_name AnimateCommand
extends Command

var _animated_sprite_2d: AnimatedSprite2D
var _animation_name: String


func _init(animated_sprite_2d: AnimatedSprite2D, animation_name: String, does_await: bool = false, data: Dictionary = {}) -> void:
	_animated_sprite_2d = animated_sprite_2d
	_animation_name = animation_name
	_does_await = does_await


func execute() -> void:
	_animated_sprite_2d.play(_animation_name)


func undo() -> void:
	if _data.has("animation_player"):
		print("data has an animation_player")
		var animation_player: AnimationPlayer = _data.get("animation_player")
		if animation_player is AnimationPlayer:
			animation_player.play_backwards(_animation_name)
			animation_player.seek(_data.get("current_animation_position"))
	else:
		_animated_sprite_2d.play_backwards(_animation_name)
		await _animated_sprite_2d.animation_finished
		finished.emit()
