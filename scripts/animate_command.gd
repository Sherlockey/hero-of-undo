class_name AnimateCommand
extends Command

var _animated_sprite_2d: AnimatedSprite2D
var _animation_name: String
var _frame_progress: float
var _frame: int


func _init(animated_sprite_2d: AnimatedSprite2D, data: Dictionary = {}) -> void:
	_animated_sprite_2d = animated_sprite_2d
	_animation_name = _animated_sprite_2d.animation
	_frame = _animated_sprite_2d.frame
	_frame_progress = _animated_sprite_2d.frame_progress


func undo() -> void:
	if _data.has("animation_player"):
		var animation_player: AnimationPlayer = _data.get("animation_player")
		if animation_player is AnimationPlayer:
			animation_player.play_backwards(_animation_name)
			animation_player.seek(_data.get("current_animation_position"))
	else:
		_animated_sprite_2d.animation = _animation_name
		_animated_sprite_2d.play_backwards(_animation_name)
		_animated_sprite_2d.set_frame_and_progress(_frame, _frame_progress)
