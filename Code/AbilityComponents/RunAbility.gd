class_name RunAbility extends AbilityNode

## The ability to run. The root node in the scene must be a subclass
## of [AbilityNode].
@export var ability: PackedScene

## Target on which to try to run an ability. Defaults to self if
## absent.
@export var target: DataSource

## Run the new ability as a main ability, i.e., attempt to interrupt a
## previous main ability. Runs as a background ability if false.
@export var main_ability: bool = true

## Start the new ability with a copy of the blackboard for the current
## ability. This can be used to pass information. Does [i]not[/i] pass
## unit-persisted data (with prefix [code]m_[/code]).
@export var copy_blackboard: bool = false

## Optional. Let the new ability reference the current unit (that runs
## this ability) by putting it in this blackboard property.
@export var source_unit_property: StringName

@export_group("Blackboard Output")

## Optional. Store a bool denoting whether the ability was started
## successfully on the blackboard. Running an ability can fail if:
## 1. The target has no [AbilityRunner].
## 2. [member RunAbility.main_ability] is true, and the previous
##    ability did not acknowledge the interrupt.
@export var success_property: StringName

func setup(a: AbilityRunner, b: Blackboard) -> void:
	if target:
		target = target.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	target.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	return target.load_state(buffer, idx)

func pre_first_process() -> void:
	target.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	if not multiplayer.is_server():
		return ARunResult.Done

	var other_runner: AbilityRunner = null

	if target:
		var other: Node2D = target.get_data(delta)
		for i in other.get_child_count():
			other_runner = other.get_child(i) as AbilityRunner
			if other_runner:
				break
	else:
		other_runner = runner

	if not other_runner:
		if success_property:
			blackboard.bset(success_property, false)
		return ARunResult.Done

	var new_blackboard := blackboard.duplicate_no_m() if copy_blackboard else Blackboard.new(runner.unit_spawner)
	if source_unit_property:
		new_blackboard.bset(source_unit_property, runner.get_parent())

	var bdata: Array = []
	new_blackboard.save_state(bdata)
	var config := {
		&"path": ability.resource_path,
		&"is_main": main_ability,
		&"blackboard": bdata,
	}

	var success := other_runner.try_run_custom_ability(config)
	if success_property:
		blackboard.bset(success_property, success)

	return ARunResult.Done
