class_name Shannon
extends Enemy

const JUMP_LAND_Y_OFFSET : float = -12.0
const IDLE_DURATION: float = 2.0

@export var projectile_scene: PackedScene
@export var jump_shadow_scene: PackedScene

var player: Player
var is_rewinding: bool = false
var attack_timer: float = 0.0
var next_attack_is_jump: bool = true
var is_attacking: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shannon: Node2D = $".."


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
		animation_player.pause()
		for command: Command in commands[commands_index]:
			command.undo()
		commands_index -= 1
		return
	else:
		current_commands.clear()
		
		var attack_timer_property_command := PropertyCommand.new(self, "attack_timer", attack_timer)
		current_commands.append(attack_timer_property_command)
		
		var is_attacking_property_command := PropertyCommand.new(self, "is_attacking", is_attacking)
		current_commands.append(is_attacking_property_command)
		
		if not is_attacking:
			attack_timer += delta
			if attack_timer >= IDLE_DURATION:
				attack_timer = 0.0
				choose_attack()
		
		var move_command := MoveCommand.new(self, position)
		current_commands.append(move_command)
		
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


func choose_attack() -> void:
	is_attacking = true
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
	if is_rewinding:
		return
	var jump_shadow: ShannonShadow = jump_shadow_scene.instantiate()
	if player != null:
		jump_shadow.global_position = player.global_position
	get_tree().root.add_child(jump_shadow)


func move_to_player() -> void:
	if is_rewinding:
		return
	var move_command := MoveCommand.new(shannon, shannon.position)
	commands[commands_index].append(move_command)
	shannon.position = player.global_position
	shannon.position.y += JUMP_LAND_Y_OFFSET


func set_area_2d_monitoring(value: bool) -> void:
	if is_rewinding:
		return
	var property_command := PropertyCommand.new(area_2d, "monitoring", !value)
	commands[commands_index].append(property_command)
	area_2d.monitoring = value


func begin_cast_animation() -> void:
	animation_player.play("cast")


func instantiate_projectiles() -> void:
	pass


func set_is_attacking(value: bool) -> void:
	if is_rewinding:
		return
	is_attacking = value


func can_rewind() -> bool:
	return commands_index >= 0
