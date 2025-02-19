class_name Enemy
extends CharacterBody2D

@export var max_health: int = 1
@export var damage: int = 1

var commands: Array[Command] = []
var commands_index: int = -1
var is_dead: bool: set = set_is_dead

@onready var health: int = max_health
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)


func take_damage(value: int) -> void:
	health -= value
	var take_damage_command := TakeDamageCommand.new(self, value)
	commands_index += 1
	commands.insert(commands_index, take_damage_command)
	if health <= 0:
		is_dead = true


func set_is_dead(value: bool) -> void:
	is_dead = value
	set_dead_variables()
	if is_dead == true:
		Global.enemy_died.emit(self)
		var die_command := DieCommand.new(self)
		commands_index += 1
		commands.insert(commands_index, die_command)
	else:
		Global.enemy_undied.emit(self)


func set_dead_variables() -> void:
	area_2d.monitoring = !is_dead
	animated_sprite_2d.visible = !is_dead
	collision_shape_2d.set_deferred("disabled", is_dead)


func _on_area_2d_body_entered(body) -> void:
	if body is Player:
		body.take_damage(damage)
