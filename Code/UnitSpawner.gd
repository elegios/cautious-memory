class_name UnitSpawner extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = do_spawn

func spawn_unit(scene: PackedScene, point: Vector2) -> Node:
	if not multiplayer.is_server():
		push_error("Called spawn_unit on non-server")
		return null

	var config := {
		&"path": scene.resource_path,
		&"point": point,
	}
	return spawn(config)

func do_spawn(config: Dictionary) -> Node:
	var path: String = config[&"path"]
	var point: Vector2 = config[&"point"]
	var scene: PackedScene = ResourceLoader.load(path)
	var node: Node2D = scene.instantiate()
	node.position = point
	return node
