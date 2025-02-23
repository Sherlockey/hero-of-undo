extends Node


func play_sound(stream: AudioStream, volume_db: float = 0.0) -> void:
	var instance := AudioStreamPlayer.new()
	instance.stream = stream
	instance.volume_db = volume_db
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()


func remove_node(instance: AudioStreamPlayer) -> void:
	instance.queue_free()
