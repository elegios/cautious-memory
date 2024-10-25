extends Node

var position_delta : Vector2

@export var interpolation_speed := 100.0

@onready var parent : Node2D = get_parent()

func _process(delta: float) -> void:
	if position_delta.is_zero_approx():
		return

	var diff := position_delta.limit_length(interpolation_speed * delta)
	position_delta -= diff
	parent.position += diff

func _physics_process(_delta: float) -> void:
	if not multiplayer or not multiplayer.is_server():
		return

	push_position(parent.position)

@rpc("unreliable_ordered", "authority", "call_remote")
func push_position(pos: Vector2) -> void:
	position_delta = pos - (parent.position + position_delta)
