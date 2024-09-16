extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const port = 12345
	var peer := ENetMultiplayerPeer.new()

	if OS.has_feature("server"):
		DisplayServer.window_set_title("(SERVER)")
		var screen_rect := DisplayServer.screen_get_usable_rect(1)
		var window_size := DisplayServer.window_get_size_with_decorations()
		var pos := screen_rect.position + screen_rect.size/2 - window_size/2
		DisplayServer.window_set_position(pos)
		var err := peer.create_server(port)
		if err == OK:
			multiplayer.multiplayer_peer = peer
		else:
			push_error("Couldn't create a server: " + error_string(err))

	if OS.has_feature("client"):
		DisplayServer.window_set_title("(CLIENT)")
		var screen_rect := DisplayServer.screen_get_usable_rect(0)
		var window_size := DisplayServer.window_get_size_with_decorations()
		var pos := screen_rect.position + screen_rect.size/2 - window_size/2
		DisplayServer.window_set_position(pos)
		var err := peer.create_client("127.0.0.1", port)
		if err == OK:
			multiplayer.multiplayer_peer = peer
		else:
			push_error("Couldn't create a client: " + error_string(err))
