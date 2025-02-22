extends Node2D

const TOP_COORDINATE_LEFT := Vector2i(7,0)
const TOP_COORDINATE_RIGHT := Vector2i(8,0)
const TILE_SET_SOURCE_ID: int = 0
const FADE_OUT_DURATION: float = 0.2

@export var next_scene: PackedScene
@export var player: Player
@export var exit_area: ExitArea
@export var left_cell_atlas_coordinates: Vector2i
@export var right_cell_atlas_coordinates: Vector2i

var alive_enemies: Array[Node]

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	Global.set_physics_process(true)
	alive_enemies = get_tree().get_nodes_in_group("enemy")
	Global.enemy_died.connect(_on_global_enemy_died)
	Global.enemy_undied.connect(_on_global_enemy_undied)
	Global.exit_area_entered.connect(_on_global_exit_area_entered)


func open_exit() -> void:
	tile_map_layer.set_cell(TOP_COORDINATE_LEFT, TILE_SET_SOURCE_ID, left_cell_atlas_coordinates)
	tile_map_layer.set_cell(TOP_COORDINATE_RIGHT, TILE_SET_SOURCE_ID, right_cell_atlas_coordinates)
	exit_area.monitoring = true


func _on_global_exit_area_entered() -> void:
	player.set_physics_process(false)
	player.play_exit_animation()
	await player.animation_player.animation_finished
	player.modulate.a = 0.0
	await get_tree().create_timer(FADE_OUT_DURATION, false).timeout
	if next_scene != null:
		get_tree().change_scene_to_packed(next_scene)
	else:
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_global_enemy_died(node: Node) -> void:
	alive_enemies.erase(node)
	if alive_enemies.size() <= 0:
		open_exit()


func _on_global_enemy_undied(node: Node) -> void:
	if not alive_enemies.has(node):
		alive_enemies.append(node)
