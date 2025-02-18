class_name Player
extends CharacterBody2D

const SPEED = 100.0
const ROLL_SPEED = 175.0

var commands: Array[Command] = []
var commands_index: int = -1
var last_direction: Vector2 = Vector2.UP
var attacking: bool
var rolling: bool
var can_roll: bool = true
var rewinding: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var roll_timer: Timer = $RollTimer
@onready var roll_cooldown_timer: Timer = $RollCooldownTimer


func _physics_process(_delta: float) -> void:
	# Rewind
	if Input.is_action_pressed("rewind") and can_rewind():
		rewinding = true
	else:
		rewinding = false
	
	if rewinding:
		commands[commands_index].undo()
		commands_index -= 1
		while not commands[commands_index].does_consume_process and can_rewind():
			commands[commands_index].undo()
			commands_index -= 1
		return
	
	# Roll
	if rolling:
		move_and_slide()
		return
	
	var animation_name: String
	
	# Attack
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		attack_timer.start()
		if last_direction == Vector2.UP:
			animated_sprite_2d.play("attack_up")
		elif last_direction == Vector2.DOWN:
			animated_sprite_2d.play("attack_down")
		elif last_direction == Vector2.LEFT:
			animated_sprite_2d.play("attack_left")
		elif last_direction == Vector2.RIGHT:
			animated_sprite_2d.play("attack_right")
	
	# Move
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
		var move_command := MoveCommand.new(self, direction * SPEED)
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
		var animate_command := AnimateCommand.new(animated_sprite_2d, animation_name)
		commands_index += 1
		commands.insert(commands_index, animate_command)
	
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
		
		animated_sprite_2d.play(animation_name)
		var animate_command := AnimateCommand.new(animated_sprite_2d, animation_name)
		commands_index += 1
		commands.insert(commands_index, animate_command)
	
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


func can_rewind() -> bool:
	return commands_index >= 0


func _on_attack_timer_timeout() -> void:
	attacking = false


func _on_roll_timer_timeout() -> void:
	rolling = false


func _on_roll_cooldown_timer_timeout() -> void:
	can_roll = true
