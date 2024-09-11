class_name Aggro extends Node

@export var vision: Area2D

@export_flags_2d_physics var player_layer: int = 1 << 4

@onready var parent: Node2D = get_parent()

func get_target_or_null() -> Node2D:
	var closest: Node2D = null

	for n in vision.get_overlapping_bodies():
		var u := n as CollisionObject2D
		if u.collision_layer & player_layer:
			if not closest or u.position.distance_squared_to(parent.position) < closest.position.distance_squared_to(parent.position):
				closest = u

	return closest
