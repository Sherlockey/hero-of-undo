extends CharacterBody2D

const SPEED = 50.0
const MIN_RAY_CAST_LENGTH: float = 20.0
const MAX_RAY_CAST_LENGTH: float = 75.0
const COORDINATE_PAIRS: Array[Vector2] = [
	Vector2(1,0), Vector2(1,-1), Vector2(0, -1), Vector2(-1,-1), 
	Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)]

@export var rng_seed: int

var rng := RandomNumberGenerator.new()
var rng_state: int
var direction: Vector2 = Vector2.ZERO
var ray_cast_length: float = 0.0

@onready var ray_cast_2d: RayCast2D = $RayCast2D


func _ready() -> void:
	rng.seed = rng_seed
	rng_state = rng.state
	choose_new_ray_cast_length()
	determine_new_direction()


func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	move_and_slide()
	
	if ray_cast_2d.is_colliding():
		choose_new_ray_cast_length()
		determine_new_direction()


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
	
	direction = new_vector
