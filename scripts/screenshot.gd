extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var path: String = "user://"
		path += str(hash(Time.get_ticks_msec()))
		path += ".png"
		print(path)
		get_viewport().get_texture().get_image().save_png(path)
