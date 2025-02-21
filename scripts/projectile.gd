class_name Projectile
extends Node2D

@export var speed: float = 40.0
@export var damage: int = 1

var current_commands: Array[Command] = []
var commands: Array = []
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
		for command: Command in commands[commands_index]:
			command.undo()
		commands_index -= 1
		return
	else:
		current_commands.clear()
		var move_command := MoveCommand.new(self, global_position)
		current_commands.append(move_command)

		global_position += direction * speed * delta
		
		if current_commands.size() > 0:
			commands_index += 1
			commands.insert(commands_index, current_commands)


func can_rewind() -> bool:
	return commands_index >= 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
	else:
		queue_free()
