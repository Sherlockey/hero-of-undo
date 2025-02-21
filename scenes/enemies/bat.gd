class_name Bat
extends Enemy

const SPEED = 50.0
const MIN_RAY_CAST_LENGTH: float = 20.0
const MAX_RAY_CAST_LENGTH: float = 75.0
const COORDINATE_PAIRS: Array[Vector2] = [
	Vector2(1,0), Vector2(1,-1), Vector2(0, -1), Vector2(-1,-1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)]

@export var rng_seed: int

var rewinding: bool = false
var rng := RandomNumberGenerator.new()
var rng_state: int
var direction: Vector2 = Vector2.ZERO
var ray_cast_length: float = 0.0

@onready var ray_cast_2d: RayCast2D = $RayCast2D


func _ready() -> void:
	super()
	rng.seed = rng_seed
	choose_new_ray_cast_length()
	determine_new_direction()

func _physics_process(delta: float) -> void:
	if Global.is_rewinding:
		if can_rewind():
			rewinding = true
		else:
			rewinding = false
			return
	else:
		rewinding = false
	
	if rewinding:
		for command in commands[commands_index]:
			command.undo()
			if command._data:
				if command._data.has("rng_state"):
					rng.state = command._data.get("rng_state")
				if command._data.has("ray_cast_length"):
					ray_cast_length = command._data.get("ray_cast_length")
				if command._data.has("ray_cast_target_position"):
					ray_cast_2d.target_position = command._data.get("ray_cast_target_position")
				if command._data.has("direction"):
					direction = command._data.get("direction")
		if commands[commands_index].size() > 0:
			commands_index -= 1
		return
	else:
		current_commands.clear()
		var data : Dictionary = {
			"rng_state" = rng.state, 
			"ray_cast_length" = ray_cast_length, 
			"ray_cast_target_position" = ray_cast_2d.target_position, 
			"direction" = direction
			}
		var move_command := MoveCommand.new(self, global_position, data)
		current_commands.append(move_command)
		
		velocity = direction * SPEED
		move_and_slide()
		
	
	if ray_cast_2d.is_colliding():
		choose_new_ray_cast_length()
		determine_new_direction()
		rng_state = rng.state
	
	if current_commands.size() > 0:
		commands_index += 1
		var array: Array[Command] = current_commands.duplicate(true)
		commands.insert(commands_index, array)


func choose_new_ray_cast_length() -> void:
	ray_cast_length = rng.randf_range(MIN_RAY_CAST_LENGTH, MAX_RAY_CAST_LENGTH)


func determine_new_direction() -> void:
	var is_ray_colliding: bool = true
	var possible_coordinates: Array[Vector2] = COORDINATE_PAIRS.duplicate()
	var new_vector: Vector2
	
	while is_ray_colliding == true:
		var size: int = possible_coordinates.size()
		var random_index: int = rng.randi_range(0, size -1)
		new_vector = possible_coordinates[random_index]
		ray_cast_2d.target_position.x = new_vector.x * ray_cast_length
		ray_cast_2d.target_position.y = new_vector.y * ray_cast_length
		ray_cast_2d.force_raycast_update()
		is_ray_colliding = ray_cast_2d.is_colliding()
		if is_ray_colliding:
			possible_coordinates.erase(new_vector)
	
	direction = new_vector.normalized()


func can_rewind() -> bool:
	return commands_index >= 0
