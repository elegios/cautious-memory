extends MultiplayerSpawner

@export
var player_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		_on_peer_connected.call_deferred(multiplayer.get_unique_id())
	var _ignore := multiplayer.peer_connected.connect(_on_peer_connected)
	pass # Replace with function body.

func _on_peer_connected(id: int) -> void:
	print("Connected peer with id: %d" % id)
	if multiplayer.is_server():
		var player : Player = player_scene.instantiate()
		player.controller = id
		player.position.x = randi() % 500
		get_parent().add_child(player, true)
	pass
