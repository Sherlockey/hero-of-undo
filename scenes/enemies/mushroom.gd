class_name Mushroom
extends Enemy

const COOLDOWN: float = 1.0

@export var projectile_scene: PackedScene

var is_attacking: bool = false
var player: Player
var is_rewinding: bool = false
var attack_timer: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	print(attack_timer)
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
		
		return
	else:
		current_commands.clear()
		
		var attack_timer_property_command := PropertyCommand.new(self, "attack_timer", attack_timer)
		current_commands.append(attack_timer_property_command)
		
		var is_attacking_property_command := PropertyCommand.new(self, "is_attacking", is_attacking)
		current_commands.append(attack_timer_property_command)
		
		if animation_player.current_animation == "idle":
			attack_timer += delta
			if attack_timer >= COOLDOWN and not is_dead:
				attack_timer = 0.0
				begin_attack_animation()
		
		#Animations
		if not is_attacking:
			animation_player.play("idle")
		
		animation_player.play()
		var data := {"animation_player" = animation_player, "current_animation_position" = animation_player.current_animation_position}
		var animate_command := AnimateCommand.new(animated_sprite_2d, data)
		current_commands.append(animate_command)
		
		if current_commands.size() > 0:
			commands_index += 1
			var array: Array[Command] = current_commands.duplicate(true)
			commands.insert(commands_index, array)


func begin_attack_animation() -> void:
	is_attacking = true
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
