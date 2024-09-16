class_name PlayerInput extends Node2D

## Zero-indexed id of the action pressed, only sent on server
signal action_pressed(id: int)

## Movement target, sent everywhere
signal move_command(target: Vector2)

var controller: int

var mouse_position: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if controller != multiplayer.get_unique_id():
		return

	mouse_position = get_viewport_transform().inverse() * get_viewport().get_mouse_position()

	if event.is_action_pressed("Action 1"):
		rpc_action.rpc_id(1, 0, mouse_position)

	if event.is_action_pressed("Action 2"):
		rpc_action.rpc_id(1, 1, mouse_position)

	if event.is_action_pressed("Action 3"):
		rpc_action.rpc_id(1, 2, mouse_position)

	if event.is_action_pressed("Move"):
		rpc_move_command.rpc(mouse_position)

func _physics_process(_delta: float) -> void:
	if controller != multiplayer.get_unique_id():
		return

	rpc_mouse_position.rpc(get_viewport_transform().inverse() * get_viewport().get_mouse_position())

@rpc("unreliable_ordered", "any_peer", "call_local", 2)
func rpc_mouse_position(target: Vector2) -> void:
	if multiplayer.get_remote_sender_id() != controller:
		return

	mouse_position = target

@rpc("reliable", "any_peer", "call_local")
func rpc_action(id: int, target: Vector2) -> void:
	if multiplayer.get_remote_sender_id() != controller:
		return

	mouse_position = target
	action_pressed.emit(id)

@rpc("unreliable_ordered", "any_peer", "call_local", 1)
func rpc_move_command(target: Vector2) -> void:
	if multiplayer.get_remote_sender_id() != controller:
		return

	mouse_position = target
	move_command.emit(target)
