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
## ability. This can be used to pass information.
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

func register_properties(root: AbilityRoot) -> void:
	if target:
		target.register_properties(self, "target", root)

func setup(a: AbilityRunner, r: AbilityRoot, b: Dictionary, register_props: bool) -> void:
	if target:
		target = target.setup(a, b)
	super(a, r, b, register_props)

func physics_process_ability(delta: float) -> ARunResult:
	return shared_process(delta)

func process_ability(_delta: float) -> ARunResult:
	return shared_process(0.0)

func shared_process(delta: float) -> ARunResult:
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
			blackboard[success_property] = false
		return ARunResult.Done

	var config := {
		&"path": ability.resource_path,
		&"is_main": main_ability,
		&"blackboard": blackboard.duplicate() if copy_blackboard else {}
	}
	if source_unit_property:
		config[&"blackboard"][source_unit_property] = runner.get_parent().get_path()

	var success := other_runner.try_run_custom_ability(config)
	if success_property:
		blackboard[success_property] = success

	return ARunResult.Done
