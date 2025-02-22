class_name Shannon
extends Enemy

const JUMP_LAND_Y_OFFSET : float = -12.0

@export var projectile_scene: PackedScene
@export var jump_shadow_scene: PackedScene

var player: Player
var is_rewinding: bool = false
var idle_duration: float = 2.0
var attack_timer: float = 0.0
var next_attack_is_jump: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shannon: Node2D = $".."


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
	else:
		current_commands.clear()
		
		var property_command := PropertyCommand.new(self, "attack_timer", attack_timer)
		current_commands.append(property_command)
		
		if not animation_player.is_playing():
			attack_timer += delta
			print(attack_timer)
			if attack_timer >= idle_duration:
				attack_timer = 0.0
				choose_attack()
		
		var move_command := MoveCommand.new(self, position)
		current_commands.append(move_command)
		
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


func choose_attack() -> void:
	if next_attack_is_jump:
		begin_jump_animation()
	else:
		begin_cast_animation()
	
	var property_command := PropertyCommand.new(self, "next_attack_is_jump", next_attack_is_jump)
	commands[commands_index].append(property_command)
	
	next_attack_is_jump = !next_attack_is_jump


func begin_jump_animation() -> void:
	animation_player.play("jump")


func instantiate_jump_shadow() -> void:
	var jump_shadow: ShannonShadow = jump_shadow_scene.instantiate()
	if player != null:
		jump_shadow.global_position = player.global_position
	get_tree().root.add_child(jump_shadow)


func move_to_player() -> void:
	var move_command := MoveCommand.new(shannon, shannon.position)
	commands[commands_index].append(move_command)
	shannon.position = player.global_position
	shannon.position.y += JUMP_LAND_Y_OFFSET


func set_area_2d_monitoring(value: bool) -> void:
	var property_command := PropertyCommand.new(area_2d, "monitoring", !value)
	commands[commands_index].append(property_command)
	area_2d.monitoring = value


func begin_cast_animation() -> void:
	animation_player.play("cast")


func instantiate_projectiles() -> void:
	pass


func can_rewind() -> bool:
	return commands_index >= 0
