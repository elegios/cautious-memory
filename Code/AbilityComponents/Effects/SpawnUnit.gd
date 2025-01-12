## Spawn a unit. NOTE: spawning only happens on the server. This means
## that for the client, one of two things will happen: 1. If the unit
## is saved to the blackboard, then this node will wait for
## confirmation from the server. 2: If the unit is [i]not[/i] saved to
## the blackboard, then execution proceeds immediately, but the unit
## won't be spawned until the server says so.
class_name SpawnUnit extends AbilityNode

## The unit (or missile) to spawn. Will set the [code]m_spawner[/code]
## blackboard property to the current unit in the spawned unit, if the
## latter has an [AbilityRunner].
@export var unit: PackedScene

## Where to spawn the unit
@export_custom(PROPERTY_HINT_EXPRESSION, "") var point: String
@onready var point_e: Expression = parse_expr(point)

@export_group("Blackboard Output")

## Optional. Save the created unit to this blackboard property. Client
## will wait for sync from server if set, otherwise completes
## immediately.
@export var unit_property: StringName

func physics_process_ability(_delta: float, _first: bool) -> ARunResult:
	if not multiplayer.is_server():
		return ARunResult.Wait if unit_property else ARunResult.Done

	var res := run_expr(point, point_e)
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not Vector2):
		return ARunResult.Error
	var spawn_point: Vector2 = res.value
	var spawned := runner.unit_spawner.spawn_unit(unit, spawn_point)
	if unit_property:
		blackboard.bset(unit_property, spawned)
	if runner.character:
		for i in spawned.get_child_count():
			var other := spawned.get_child(i) as AbilityRunner
			if other:
				other.unit_local.bset(&"m_spawner", runner.character)
				break
	return ARunResult.Done
