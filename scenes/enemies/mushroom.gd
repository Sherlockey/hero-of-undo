class_name Mushroom
extends Enemy

@export var projectile_scene: PackedScene

var player: Player
var is_rewinding: bool = false
var is_attacking: bool =  false : set = set_is_attacking
var cooldown: float = 1.0
var time: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")


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
		for command: Command in commands[commands_index]:
			command.undo()
		commands_index -= 1
		
		if not is_attacking:
			time -= delta
			if time < 0.0:
				time = 1.0 + time
		return
	else:
		current_commands.clear()
		
		if not is_attacking:
			time += delta
		
		if time >= cooldown:
			if not is_dead:
				is_attacking = true
				time = 0.0
				begin_attack_animation()
		
		#Animations
		if animation_player.is_playing():
			var data := {"animation_player" = animation_player, "current_animation_position" = animation_player.current_animation_position}
			var animate_command := AnimateCommand.new(animated_sprite_2d, data)
			current_commands.append(animate_command)
		else:
			animated_sprite_2d.play("idle")
			var animate_command := AnimateCommand.new(animated_sprite_2d)
			current_commands.append(animate_command)
		
		if current_commands.size() > 0:
			commands_index += 1
			var array: Array[Command] = current_commands.duplicate(true)
			commands.insert(commands_index, array)


func begin_attack_animation() -> void:
	animated_sprite_2d.animation = "attack"
	animation_player.play("attack")


func attack() -> void:
	if is_rewinding:
		return
	if player != null:
		var projectile: Projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.direction = Vector2.RIGHT.rotated(get_angle_to(player.global_position))
		get_tree().root.add_child(projectile)


func set_is_attacking(value: bool) -> void:
	if is_rewinding:
		return
	is_attacking = value


func can_rewind() -> bool:
	return commands_index >= 0
