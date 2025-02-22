class_name ShannonShadow
extends Node2D

const VISIBLE_DURATION: float = 0.75

var current_commands: Array[Command] = []
var commands: Array = []
var commands_index: int = -1
var is_rewinding: bool = false
var duration: float = 0.0


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
		
		if duration >= VISIBLE_DURATION and visible == true:
			var visible_property_command := PropertyCommand.new(self, "visible", true)
			current_commands.append(visible_property_command)
			visible = false
	
		var duration_property_command := PropertyCommand.new(self, "duration", duration)
		current_commands.append(duration_property_command)
		duration += delta
		
		var move_command := MoveCommand.new(self, global_position)
		current_commands.append(move_command)
		
		if current_commands.size() > 0:
			commands_index += 1
			var array: Array[Command] = current_commands.duplicate(true)
			commands.insert(commands_index, array)


func can_rewind() -> bool:
	return commands_index >= 0
