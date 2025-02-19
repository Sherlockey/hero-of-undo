class_name Player
extends CharacterBody2D

const SPEED = 100.0
const ROLL_SPEED = 175.0

var commands: Array[Command] = []
var commands_index: int = -1
var last_direction: Vector2 = Vector2.UP
var rolling: bool
var can_roll: bool = true
var rewinding: bool = false
var awaiting: bool = false
var damage: int = 1
var health: int = 1
var is_dead: bool = false: set = set_is_dead
var attacking: bool: set = set_attacking

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var roll_timer: Timer = $RollTimer
@onready var roll_cooldown_timer: Timer = $RollCooldownTimer
@onready var attack_area: Area2D = $AttackArea


func _physics_process(_delta: float) -> void:
	if awaiting:
		return
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
		if commands[commands_index]._does_await:
			commands[commands_index].undo()
			awaiting = true
			await commands[commands_index].finished
			awaiting = false
			commands_index -= 1
		else:
			commands[commands_index].undo()
			commands_index -= 1
		while not commands[commands_index].does_consume_process and can_rewind():
			if commands[commands_index]._does_await:
				commands[commands_index].undo()
				awaiting = true
				await commands[commands_index].finished
				awaiting = false
				commands_index -= 1
			else:
				commands[commands_index].undo()
				commands_index -= 1
		return
	
	# Dead
	if is_dead:
		return
	
	# Roll
	if rolling:
		move_and_slide()
		var move_command := MoveCommand.new(self, velocity)
		commands_index += 1
		commands.insert(commands_index, move_command)
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
		var attack_command := AnimateCommand.new(animated_sprite_2d, animation_name, true)
		commands_index += 1
		commands.insert(commands_index, attack_command)
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
		
		velocity = direction * ROLL_SPEED
		move_and_slide()
		var move_command := MoveCommand.new(self, velocity)
		commands_index += 1
		commands.insert(commands_index, move_command)
		
		if last_direction == Vector2.UP:
			animation_name = "roll_up"
		elif last_direction == Vector2.DOWN:
			animation_name = "roll_down"
		elif last_direction == Vector2.LEFT:
			animation_name = "roll_left"
		elif last_direction == Vector2.RIGHT:
			animation_name = "roll_right"
		
		animated_sprite_2d.play(animation_name)
		animated_sprite_2d.animation_finished.connect(_on_animation_finished.bind(animation_name))
		return
	
	# Normal movement
	if not attacking and not rolling:
		velocity = direction * SPEED
		move_and_slide()
		var move_command := MoveCommand.new(self, direction * SPEED)
		commands_index += 1
		commands.insert(commands_index, move_command)
		
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
	var animate_command := AnimateCommand.new(animated_sprite_2d, animation_name)
	commands_index += 1
	commands.insert(commands_index, animate_command)


func take_damage(value: int) -> void:
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
		commands_index += 1
		commands.insert(commands_index, die_command)
		Engine.time_scale = 0.0


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


func _on_animation_finished(animation_name: String) -> void:
	var animate_command := AnimateCommand.new(animated_sprite_2d, animation_name)
	commands_index += 1
	commands.insert(commands_index, animate_command)
	animated_sprite_2d.animation_finished.disconnect(_on_animation_finished)


func _on_attack_timer_timeout() -> void:
	attacking = false


func _on_roll_timer_timeout() -> void:
	rolling = false


func _on_roll_cooldown_timer_timeout() -> void:
	can_roll = true


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)
