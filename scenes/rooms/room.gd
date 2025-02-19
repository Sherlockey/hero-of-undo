extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var alive_enemies: Array[Node]


func _ready() -> void:
	alive_enemies = get_tree().get_nodes_in_group("enemy")
	Global.enemy_died.connect(_on_global_enemy_died)
	Global.enemy_undied.connect(_on_global_enemy_undied)


func _on_global_enemy_died(node: Node) -> void:
	alive_enemies.erase(node)
	if alive_enemies.size() <= 0:
		tile_map_layer.set_cell(Vector2i(7, 0), 0, Vector2i(3,0))
		tile_map_layer.set_cell(Vector2i(8, 0), 0, Vector2i(4,0))


func _on_global_enemy_undied(node: Node) -> void:
	if not alive_enemies.has(node):
		alive_enemies.append(node)
