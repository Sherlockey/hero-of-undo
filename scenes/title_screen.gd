extends Node2D

const FADE_OUT_DURATION: float = 0.2

@export var next_scene: PackedScene
@export var audio_bus_layout = preload("res://resources/new_audio_bus_layout.tres")

var waiting_for_input: bool = true

@onready var player: Player = $Player
@onready var control_animation_player: AnimationPlayer = %ControlAnimationPlayer


func _ready() -> void:
	AudioServer.set_bus_layout(audio_bus_layout)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.animated_sprite_2d.play("idle_down")
	player.set_physics_process(false)
	Global.set_physics_process(false)
	Global.exit_area_entered.connect(_on_global_exit_area_entered)


func _physics_process(delta: float) -> void:
	if waiting_for_input:
		if Input.is_anything_pressed():
			waiting_for_input = false
			control_animation_player.play("fade_out")
			await control_animation_player.animation_finished
			player.set_physics_process(true)


func _on_global_exit_area_entered() -> void:
	player.set_physics_process(false)
	player.play_exit_animation()
	await player.animation_player.animation_finished
	player.modulate.a = 0.0
	await get_tree().create_timer(FADE_OUT_DURATION, false).timeout
	get_tree().change_scene_to_packed(next_scene)
