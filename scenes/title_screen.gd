extends Node2D

const FADE_OUT_DURATION: float = 0.2

@export var next_scene: PackedScene

var waiting_for_input: bool = true
var mouse_and_keyboard: bool
var can_show_input: bool = false
var has_shown_input: bool = false

@onready var player: Player = $Player
@onready var control_animation_player: AnimationPlayer = %ControlAnimationPlayer
@onready var mouse_and_keyboard_controls: Control = %MouseAndKeyboardControls
@onready var joypad_controls: Control = %JoypadControls
@onready var inputs_animation_player: AnimationPlayer = %InputsAnimationPlayer


func _ready() -> void:
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
			Global.set_physics_process(true)
			can_show_input = true
	elif can_show_input:
		mouse_and_keyboard_controls.visible = mouse_and_keyboard
		joypad_controls.visible = !mouse_and_keyboard
		if not has_shown_input:
			has_shown_input = true
			inputs_animation_player.play("fade_in")


func _input(event: InputEvent) -> void:
	if (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		mouse_and_keyboard = false
	else:
		mouse_and_keyboard = true


func _on_global_exit_area_entered() -> void:
	player.set_physics_process(false)
	player.play_exit_animation()
	await player.animation_player.animation_finished
	player.modulate.a = 0.0
	await get_tree().create_timer(FADE_OUT_DURATION, false).timeout
	get_tree().change_scene_to_packed(next_scene)
