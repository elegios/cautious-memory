extends Node

## Emitted on the server when a character is chosen the [i]first[/i]
## time.
signal character_chosen(id: int)

@export var player_characters : Array[PackedScene]

@onready var choices : ItemList = %Choices
@onready var ui : Control = %UI

## Map from player_id to PData
var player_data : Dictionary

func _ready() -> void:
	for p in player_characters:
		var _idx := choices.add_item(p.resource_path)
	if multiplayer.is_server():
		_on_peer_connected(multiplayer.get_unique_id())
	var _ignore := multiplayer.peer_connected.connect(_on_peer_connected)
	_ignore = multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int) -> void:
	player_data[id] = PData.new()

func _on_peer_disconnected(id: int) -> void:
	var _ignore := player_data.erase(id)

func get_character(player_id: int) -> PackedScene:
	var data : PData = player_data.get(player_id, null)
	return data.chosen_character if data else null

func _on_button_pressed() -> void:
	var selected := choices.get_selected_items()
	if selected.is_empty():
		return

	choose_character.rpc_id(1, selected[0])
	ui.visible = false

@rpc("call_local", "any_peer", "reliable")
func choose_character(idx: int) -> void:
	var data : PData = player_data[multiplayer.get_remote_sender_id()]
	var first_selection := not data.chosen_character
	data.chosen_character = player_characters[idx]
	if first_selection:
		character_chosen.emit(multiplayer.get_remote_sender_id())

func request_choice(id: int) -> void:
	_do_request_choice.rpc_id(id)

@rpc("authority", "call_local", "reliable")
func _do_request_choice() -> void:
	ui.visible = true

class PData extends RefCounted:
	var chosen_character : PackedScene
