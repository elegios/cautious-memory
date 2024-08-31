## Spawn a unit. NOTE: spawning only happens on the server. This means
## that for the client, one of two things will happen: 1. If the unit
## is saved to the blackboard, then this node will wait for
## confirmation from the server. 2: If the unit is [i]not[/i] saved to
## the blackboard, then execution proceeds immediately, but the unit
## won't be spawned until the server says so.
class_name SpawnUnit extends AbilityNode

## The unit (or missile) to spawn
@export var unit: PackedScene

@export_group("Blackboard Output")

## Optional. Save the created unit to this blackboard property.
@export var unit_property: StringName

var spawned_path: NodePath

func pre_first_process() -> void:
	if multiplayer.is_server():
		var spawned := runner.unit_spawner.spawn_unit(unit)
		rpc_notify_spawned.rpc(spawned)
	else:
		spawned_path = ^""

func physics_process_ability(_delta: float) -> ARunResult:
	if multiplayer.is_server() or not unit_property:
		return ARunResult.Done
	if spawned_path:
		blackboard[unit_property] = spawned_path
		return ARunResult.Done
	return ARunResult.Wait

@rpc("reliable", "authority", "call_remote")
func rpc_notify_spawned(path: NodePath) -> void:
	spawned_path = path
