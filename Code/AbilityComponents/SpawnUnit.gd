## Spawn a unit. NOTE: spawning only happens on the server. This means
## that for the client, one of two things will happen: 1. If the unit
## is saved to the blackboard, then this node will wait for
## confirmation from the server. 2: If the unit is [i]not[/i] saved to
## the blackboard, then execution proceeds immediately, but the unit
## won't be spawned until the server says so.
class_name SpawnUnit extends AbilityNode

## The unit (or missile) to spawn
@export var unit: PackedScene

@export var point: DataSource

@export_group("Blackboard Output")

## Optional. Save the created unit to this blackboard property. Client
## will wait for sync from server if set, otherwise completes
## immediately.
@export var unit_property: StringName

func setup(a: AbilityRunner, b: Blackboard) -> void:
	point = point.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	point.save_state(buffer)
	super(buffer)

func load_state(buffer: Array, idx: int) -> int:
	idx = point.load_state(buffer, idx)
	return super(buffer, idx)

func pre_first_process() -> void:
	point.pre_first_data()
	if multiplayer.is_server():
		var spawn_point: Vector2 = point.get_data(0.0)
		var spawned := runner.unit_spawner.spawn_unit(unit, spawn_point)
		if unit_property:
			blackboard.bset(unit_property, spawned)

func physics_process_ability(_delta: float) -> ARunResult:
	if multiplayer.is_server() or not unit_property:
		return ARunResult.Done
	return ARunResult.Wait
