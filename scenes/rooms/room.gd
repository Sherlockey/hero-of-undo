extends Node2D

const TOP_COORDINATE_LEFT := Vector2i(7,0)
const TOP_COORDINATE_RIGHT := Vector2i(8,0)
const TILE_SET_SOURCE_ID: int = 0

@export var exit_area: ExitArea
@export var left_cell_atlas_coordinates: Vector2i
@export var right_cell_atlas_coordinates: Vector2i

var alive_enemies: Array[Node]

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	alive_enemies = get_tree().get_nodes_in_group("enemy")
	Global.enemy_died.connect(_on_global_enemy_died)
	Global.enemy_undied.connect(_on_global_enemy_undied)


func open_exit() -> void:
	tile_map_layer.set_cell(TOP_COORDINATE_LEFT, TILE_SET_SOURCE_ID, left_cell_atlas_coordinates)
	tile_map_layer.set_cell(TOP_COORDINATE_RIGHT, TILE_SET_SOURCE_ID, right_cell_atlas_coordinates)
	exit_area.monitoring = true


func _on_global_enemy_died(node: Node) -> void:
	alive_enemies.erase(node)
	if alive_enemies.size() <= 0:
		open_exit()


func _on_global_enemy_undied(node: Node) -> void:
	if not alive_enemies.has(node):
		alive_enemies.append(node)
