class_name UnitSpawner extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = do_spawn

func spawn_unit(scene: PackedScene) -> Node:
	if not multiplayer.is_server():
		push_error("Called spawn_unit on non-server")
		return null

	return spawn(scene.resource_path)

func do_spawn(path: String) -> Node:
	var scene: PackedScene = ResourceLoader.load(path)
	return scene.instantiate()
