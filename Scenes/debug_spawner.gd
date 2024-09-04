extends Node

@export var player_scene : PackedScene
@export var spawner : UnitSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		_on_peer_connected.call_deferred(multiplayer.get_unique_id())
	var _ignore := multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id: int) -> void:
	print("Connected peer with id: %d" % id)
	if multiplayer.is_server():
		var player: Player = spawner.spawn_unit(player_scene, Vector2(randi() % 500, 0))
		player.controller = id
