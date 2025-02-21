class_name Projectile
extends Node2D

@export var speed: float = 40.0
@export var damage: int = 1

var commands: Array[Command] = []
var commands_index: int = -1
var direction := Vector2.RIGHT
var is_rewinding: bool = false


func _physics_process(delta: float) -> void:
	if Global.is_rewinding:
		if can_rewind():
			is_rewinding = true
		else:
			is_rewinding = false
			queue_free()
			return
	else:
		is_rewinding = false
	
	if is_rewinding:
		commands[commands_index].undo()
		commands_index -= 1
		return
	else:
		var move_command := MoveCommand.new(self, global_position)
		commands_index += 1
		commands.insert(commands_index, move_command)

		global_position += direction * speed * delta


func can_rewind() -> bool:
	return commands_index >= 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
	else:
		queue_free()
