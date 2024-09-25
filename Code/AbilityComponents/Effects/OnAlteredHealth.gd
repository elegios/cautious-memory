@tool
## Listen for [AlterHealth] events on the current unit, possibly
## modifying the delta applied and doing something in response.
class_name OnAlteredHealth extends AbilityTriggered

## Whether to finish after the first health alteration event or keep
## listening indefinitely.
@export var continuous := false

## The altered health delta to apply. The initial value is available
## as [code]delta[/code].
@export var new_delta: String = "delta"
@onready var new_delta_e: Expression = parse_expr(new_delta, ["delta"])

@export_group("Blackboard Output")

## Optional. Write the initial [code]delta[/code] value to this
## blackboard property. Not written if absent.
@export var initial_delta: StringName

## Optional. Write the [code]delta[/code] value [i]after[/i] applying
## the change via [property OnAlteredHealth.new_delta] to this
## blackboard property. Not written if absent.
@export var altered_delta: StringName

var done := false

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"new_delta":
			property.hint = PROPERTY_HINT_EXPRESSION

func sync_lost() -> void:
	runner.health.unregister_modifier(_on_health_event)

func pre_first_process() -> void:
	runner.health.register_modifier(_on_health_event)
	done = false

func sync_gained() -> void:
	pre_first_process()

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var res := super(kind)
	if kind == AInterruptResult.Interrupted:
		runner.health.unregister_modifier(_on_health_event)
	return res

func physics_process_ability(_delta: float) -> ARunResult:
	if done:
		runner.health.unregister_modifier(_on_health_event)
		return ARunResult.Done

	return ARunResult.Wait

func _on_health_event(delta: float) -> float:
	var altered_delta_value: float = run_expr(new_delta, new_delta_e, [delta])

	if initial_delta:
		blackboard.bset(initial_delta, delta)
	if altered_delta:
		blackboard.bset(altered_delta, altered_delta_value)

	trigger()

	done = not continuous

	return altered_delta_value
