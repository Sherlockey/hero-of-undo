class_name Player
extends CharacterBody2D

const SPEED = 100.0

var last_direction: Vector2 = Vector2.UP
var attacking: bool

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer


func _physics_process(_delta: float) -> void:
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
	if not attacking:
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
	if direction == Vector2.ZERO and not attacking:
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
