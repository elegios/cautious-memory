extends MultiplayerSpawner

@export var initial_level: PackedScene

@onready var connect_interface: Control = %"ConnectInterface"
@onready var status_display: Label = %"Status"

var adress: String = "localhost"
var port: int = 12345

var current_level: Node

@onready var peer := ENetMultiplayerPeer.new()

func _ready() -> void:
	spawn_function = _load_level
	var _ignore := multiplayer.connected_to_server.connect(_on_connect_success)
	_ignore = multiplayer.server_disconnected.connect(_on_server_disconnected)
	_ignore = multiplayer.connection_failed.connect(_on_connect_fail)
	_setup()

func _setup() -> void:
	if OS.has_feature("server"):
		DisplayServer.window_set_title("(SERVER)")
		var screen_rect := DisplayServer.screen_get_usable_rect(1)
		var window_size := DisplayServer.window_get_size_with_decorations()
		var pos := screen_rect.position + screen_rect.size/2 - window_size/2
		DisplayServer.window_set_position(pos)
		_on_host_pressed()

	if OS.has_feature("client"):
		DisplayServer.window_set_title("(CLIENT)")
		var screen_rect := DisplayServer.screen_get_usable_rect(0)
		var window_size := DisplayServer.window_get_size_with_decorations()
		var pos := screen_rect.position + screen_rect.size/2 - window_size/2
		DisplayServer.window_set_position(pos)
		_on_connect_pressed()

func _update_adress(new: String) -> void:
	adress = new

func _update_port(new: String) -> void:
	if new.is_valid_int():
		port = new.to_int()

func _on_host_pressed() -> void:
	var err := peer.create_server(port)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		switch_level(initial_level)
		_on_connect_success()
	else:
		push_error("Couldn't create a server: " + error_string(err))

func _on_connect_pressed() -> void:
	var err := peer.create_client(adress, port)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		status_display.text = "Connecting..."
	else:
		push_error("Couldn't create a client: " + error_string(err))

## Destructively switch to another level. Does nothing on a client.
func switch_level(level: PackedScene) -> void:
	if not multiplayer.is_server():
		return

	if current_level:
		current_level.queue_free()
	current_level = spawn(level.resource_path)

func _load_level(path: String) -> Node:
	var packed_scene : PackedScene = ResourceLoader.load(path)
	var scene := packed_scene.instantiate()
	return scene

func _on_connect_fail() -> void:
	connect_interface.visible = true
	status_display.text = "Connection failed"

func _on_server_disconnected() -> void:
	connect_interface.visible = true
	status_display.text = "Server disconnected"

func _on_connect_success() -> void:
	connect_interface.visible = false
