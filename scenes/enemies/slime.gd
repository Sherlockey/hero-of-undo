class_name Slime
extends Enemy

const SPEED = 30.0

var player: Player
var is_rewinding: bool = false
var direction: float = 0.0
var step: float = TAU/8


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if Global.is_rewinding:
		if can_rewind():
			is_rewinding = true
		else:
			is_rewinding = false
			return
	else:
		is_rewinding = false
	
	if is_rewinding:
		for command in commands[commands_index]:
			command.undo()
		if commands[commands_index].size() > 0:
			commands_index -= 1
		return
	else:
		current_commands.clear()
		
		var move_command := MoveCommand.new(self, global_position)
		current_commands.append(move_command)
		
		direction = global_position.angle_to_point(player.global_position)
		direction = snapped(direction, step)
		velocity = Vector2.RIGHT.rotated(direction) * SPEED
		move_and_slide()
		
		if current_commands.size() > 0:
			commands_index += 1
			var array: Array[Command] = current_commands.duplicate(true)
			commands.insert(commands_index, array)


func can_rewind() -> bool:
	return commands_index >= 0
