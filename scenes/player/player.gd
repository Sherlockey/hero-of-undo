class_name Player
extends CharacterBody2D

const SPEED = 100.0
const ROLL_SPEED = 175.0

@export var last_direction: Vector2 = Vector2.UP

var current_commands: Array[Command] = []
var commands: Array = []
var commands_index: int = -1
var rolling: bool
var can_roll: bool = true
var rewinding: bool = false
var damage: int = 1
var health: int = 1
var is_dead: bool = false: set = set_is_dead
var attacking: bool: set = set_attacking

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var roll_timer: Timer = $RollTimer
@onready var roll_cooldown_timer: Timer = $RollCooldownTimer
@onready var attack_area: Area2D = $AttackArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _physics_process(_delta: float) -> void:
	# Rewind
	if Global.is_rewinding:
		if can_rewind():
			rewinding = true
		else:
			rewinding = false
			return
	else:
		rewinding = false
	
	if rewinding:
		for command: Command in commands[commands_index]:
			command.undo()
		commands_index -= 1
		return
	
	# Dead
	if is_dead:
		return
	
	# Clear current_commands so it is ready to accept new commands this frame
	current_commands.clear()
	
	# Roll
	if rolling:
		var move_command := MoveCommand.new(self, global_position)
		current_commands.append(move_command)
		
		move_and_slide()
		
		if current_commands.size() > 0:
			commands_index += 1
			var array: Array[Command] = current_commands.duplicate(true)
			commands.insert(commands_index, array)
		return
	
	# Declare Animation Name
	var animation_name: String
	
	# Attack
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		attack_timer.start()
		if last_direction == Vector2.UP:
			animation_name = "attack_up"
		elif last_direction == Vector2.DOWN:
			animation_name = "attack_down"
		elif last_direction == Vector2.LEFT:
			animation_name = "attack_left"
		elif last_direction == Vector2.RIGHT:
			animation_name = "attack_right"
		
		animated_sprite_2d.play(animation_name)
		var attack_animate_command := AnimateCommand.new(animated_sprite_2d)
		current_commands.append(attack_animate_command)
		
		if current_commands.size() > 0:
			commands_index += 1
			var array: Array[Command] = current_commands.duplicate(true)
			commands.insert(commands_index, array)
		return
	
	# Get Direction
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Start rolling
	if Input.is_action_just_pressed("roll") and not rolling and not attacking and can_roll:
		rolling = true
		can_roll = false
		roll_timer.start()
		roll_cooldown_timer.start()
		if direction == Vector2.ZERO:
			direction = last_direction
		
		var move_command := MoveCommand.new(self, global_position)
		current_commands.append(move_command)
		
		velocity = direction * ROLL_SPEED
		move_and_slide()
		
		if last_direction == Vector2.UP:
			animation_name = "roll_up"
		elif last_direction == Vector2.DOWN:
			animation_name = "roll_down"
		elif last_direction == Vector2.LEFT:
			animation_name = "roll_left"
		elif last_direction == Vector2.RIGHT:
			animation_name = "roll_right"
		
		animated_sprite_2d.play(animation_name)
		var roll_animate_command := AnimateCommand.new(animated_sprite_2d)
		current_commands.append(roll_animate_command)
		
		if current_commands.size() > 0:
			commands_index += 1
			var array: Array[Command] = current_commands.duplicate(true)
			commands.insert(commands_index, array)
		return
	
	# Normal movement
	if not attacking and not rolling:
		var move_command := MoveCommand.new(self, global_position)
		current_commands.append(move_command)
		
		velocity = direction * SPEED
		move_and_slide()
		
		# Move Animations
		if direction.y < -0.7:
			animation_name = "move_up"
			last_direction = Vector2.UP
		elif direction.y > 0.7:
			animation_name = "move_down"
			last_direction = Vector2.DOWN
		elif direction.x < -0.7:
			animation_name = "move_left"
			last_direction = Vector2.LEFT
		elif direction.x > 0.7:
			animation_name = "move_right"
			last_direction = Vector2.RIGHT
	
	if direction == Vector2.ZERO and not attacking and not rolling:
		if last_direction == Vector2.UP:
			animation_name = "idle_up"
		elif last_direction == Vector2.DOWN:
			animation_name = "idle_down"
		elif last_direction == Vector2.LEFT:
			animation_name = "idle_left"
		elif last_direction == Vector2.RIGHT:
			animation_name = "idle_right"
		
	animated_sprite_2d.play(animation_name)
	var animate_command := AnimateCommand.new(animated_sprite_2d)
	current_commands.append(animate_command)
	
	# Finally insert current commands to commands at commands_index
	if current_commands.size() > 0:
		commands_index += 1
		var array: Array[Command] = current_commands.duplicate(true)
		commands.insert(commands_index, array)


func take_damage(value: int) -> void:
	if not rolling:
		health -= value
		if health <= 0:
			is_dead = true


func can_rewind() -> bool:
	if commands_index >= 0:
		return true
	else:
		return false


func set_is_dead(value: bool) -> void:
	is_dead = value
	
	if is_dead == true:
		var die_command := DieCommand.new(self)
		commands[commands_index].append(die_command)
		get_tree().paused = true


func set_attacking(value: bool) -> void:
	attacking = value
	
	if last_direction == Vector2.UP:
		attack_area.rotation_degrees = 0.0
	if last_direction == Vector2.DOWN:
		attack_area.rotation_degrees = 180.0
	if last_direction == Vector2.LEFT:
		attack_area.rotation_degrees = 270.0
	if last_direction == Vector2.RIGHT:
		attack_area.rotation_degrees = 90.0
	
	attack_area.monitoring = value


func play_exit_animation() -> void:
	animation_player.play("exit")


func _on_attack_timer_timeout() -> void:
	attacking = false


func _on_roll_timer_timeout() -> void:
	rolling = false


func _on_roll_cooldown_timer_timeout() -> void:
	can_roll = true


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)
