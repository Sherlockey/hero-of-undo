class_name ExitArea
extends Area2D

@export var audio_stream: AudioStream


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.exit_area_entered.emit()
		SoundEffects.play_sound(audio_stream, 15.0)
