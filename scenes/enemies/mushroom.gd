class_name Mushroom
extends Enemy

@export var projectile_scene: PackedScene

var player: Player
var is_rewinding: bool = false
var cooldown: float = 1.0

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	attack_cooldown_timer.wait_time = cooldown
	attack_cooldown_timer.start()


func _physics_process(delta: float) -> void:
	if Global.is_rewinding:
		if can_rewind():
			is_rewinding = true
		else:
			is_rewinding = false
			return
	else:
		is_rewinding = false
	
	if is_rewinding:
		for command in commands[commands_index]:
			command.undo()
		if commands[commands_index].size() > 0:
			commands_index -= 1
		return
	else:
		current_commands.clear()
		
		if animation_player.is_playing():
			var data := {"animation_player" = animation_player, "current_animation_position" = animation_player.current_animation_position}
			var animate_command := AnimateCommand.new(animated_sprite_2d, data)
			current_commands.append(animate_command)
		else:
			var animate_command := AnimateCommand.new(animated_sprite_2d)
			current_commands.append(animate_command)
		
	if current_commands.size() > 0:
		commands_index += 1
		var array: Array[Command] = current_commands.duplicate(true)
		commands.insert(commands_index, array)


func begin_attack_animation() -> void:
	animated_sprite_2d.stop()
	animated_sprite_2d.animation = "attack"
	animation_player.play("attack")


func attack() -> void:
	if player != null:
		var projectile: Projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.direction = Vector2.RIGHT.rotated(get_angle_to(player.global_position))
		get_tree().root.add_child(projectile)


func start_idle_animation() -> void:
	animated_sprite_2d.play("idle")


func start_attack_cooldown_timer() -> void:
		attack_cooldown_timer.wait_time = cooldown
		attack_cooldown_timer.start()


func can_rewind() -> bool:
	return commands_index >= 0


func _on_shoot_cooldown_timer_timeout() -> void:
	if not is_dead:
		begin_attack_animation()
