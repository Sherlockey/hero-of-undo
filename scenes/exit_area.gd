class_name ExitArea
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.exit_area_entered.emit()
