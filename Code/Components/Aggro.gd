class_name Aggro extends Node

@export var vision: Area2D

## The layer on which to search for players we might aggro to.
@export_flags_2d_physics var player_layer: int = 1 << 4

@export_group("Blackboard Output")

## The blackboard property to store the current target under. Should
## start with [code]m_[/code], otherwise abilities won't see it.
@export var target_property: StringName = &"m_target"

## The [AbilityRunner] of the unit, i.e., where to store the data
@export var runner: AbilityRunner

@onready var parent: Node2D = get_parent()

func get_target_or_null() -> Node2D:
	var closest: Node2D = null

	for n in vision.get_overlapping_bodies():
		var u := n as CollisionObject2D
		if u.collision_layer & player_layer:
			if not closest or u.position.distance_squared_to(parent.position) < closest.position.distance_squared_to(parent.position):
				closest = u

	if runner:
		runner.unit_local.bset(target_property, closest)

	return closest
