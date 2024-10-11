@icon("../Icons/RunAbility.svg")
@tool
## Run an ability on a unit.
class_name RunAbility extends AbilityNode

## The ability to run. The root node in the scene must be a subclass
## of [AbilityNode].
@export var ability: PackedScene

## Target on which to try to run an ability. Defaults to self if
## absent.
@export var target: String
@onready var target_e: Expression = parse_expr(target) if target else null

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"target":
			property.hint = PROPERTY_HINT_EXPRESSION

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

func physics_process_ability(_delta: float) -> ARunResult:
	if not multiplayer.is_server():
		return ARunResult.Done

	var other_runner: AbilityRunner = null

	if target:
		var res := run_expr(target, target_e)
		if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not Node2D):
			return ARunResult.Error
		var other: Node2D = res.value
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
