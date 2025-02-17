class_name Player
extends CharacterBody2D

const SPEED = 100.0
const ROLL_SPEED = 175.0

var last_direction: Vector2 = Vector2.UP
var attacking: bool
var rolling: bool
var can_roll: bool = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var roll_timer: Timer = $RollTimer
@onready var roll_cooldown_timer: Timer = $RollCooldownTimer


func _physics_process(_delta: float) -> void:
	if rolling:
		move_and_slide()
	
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
	
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("roll") and not rolling and not attacking and can_roll:
		rolling = true
		can_roll = false
		roll_timer.start()
		roll_cooldown_timer.start()
		if direction == Vector2.ZERO:
			direction = last_direction
		
		velocity = direction * ROLL_SPEED
		move_and_slide()
		
		if last_direction == Vector2.UP:
			animated_sprite_2d.play("roll_up")
		elif last_direction == Vector2.DOWN:
			animated_sprite_2d.play("roll_down")
		elif last_direction == Vector2.LEFT:
			animated_sprite_2d.play("roll_left")
		elif last_direction == Vector2.RIGHT:
			animated_sprite_2d.play("roll_right")
	
	if not attacking and not rolling:
		velocity = direction * SPEED
		move_and_slide()
		
		# Animations
		if direction.y < -0.7:
			animated_sprite_2d.play("move_up")
			last_direction = Vector2.UP
		elif direction.y > 0.7:
			animated_sprite_2d.play("move_down")
			last_direction = Vector2.DOWN
		elif direction.x < -0.7:
			animated_sprite_2d.play("move_left")
			last_direction = Vector2.LEFT
		elif direction.x > 0.7:
			animated_sprite_2d.play("move_right")
			last_direction = Vector2.RIGHT
	if direction == Vector2.ZERO and not attacking and not rolling:
		if last_direction == Vector2.UP:
			animated_sprite_2d.play("idle_up")
		elif last_direction == Vector2.DOWN:
			animated_sprite_2d.play("idle_down")
		elif last_direction == Vector2.LEFT:
			animated_sprite_2d.play("idle_left")
		elif last_direction == Vector2.RIGHT:
			animated_sprite_2d.play("idle_right")


func _on_attack_timer_timeout() -> void:
	attacking = false


func _on_roll_timer_timeout() -> void:
	rolling = false


func _on_roll_cooldown_timer_timeout() -> void:
	can_roll = true
