class_name UnitSpawner extends MultiplayerSpawner

var next_id: int = 0
var id_to_unit: Dictionary = {}
var unit_to_id: Dictionary = {}

func _ready() -> void:
	spawn_function = do_spawn
	var _connected := get_node(spawn_path).child_exiting_tree.connect(cleanup_node)

func spawn_unit(scene: PackedScene, point: Vector2) -> Node:
	if not multiplayer.is_server():
		push_error("Called spawn_unit on non-server")
		return null

	var config := {
		&"path": scene.resource_path,
		&"point": point,
		&"id": next_id,
	}
	next_id += 1
	return spawn(config)

func do_spawn(config: Dictionary) -> Node:
	var path: String = config[&"path"]
	var point: Vector2 = config[&"point"]
	var id: int = config[&"id"]
	var scene: PackedScene = ResourceLoader.load(path)
	var node: Node2D = scene.instantiate()
	node.position = point
	id_to_unit[id] = node
	unit_to_id[node] = id
	return node

func cleanup_node(node: Node) -> void:
	if not unit_to_id.has(node):
		return

	var id: int = unit_to_id[node]
	var _ignore := id_to_unit.erase(id)
	_ignore = unit_to_id.erase(node)
