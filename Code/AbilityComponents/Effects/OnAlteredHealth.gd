## Listen for [AlterHealth] events on the current unit, possibly
## modifying the delta applied and doing something in response.
class_name OnAlteredHealth extends AbilityTriggered

## Whether to finish after the first health alteration event or keep
## listening indefinitely.
@export var continuous := false

## The altered health delta to apply. The initial value is available
## as [code]delta[/code].
@export_custom(PROPERTY_HINT_EXPRESSION, "") var new_delta: String = "delta"
@onready var new_delta_e: Expression = parse_expr(new_delta, ["delta"])

## An optional condition limiting when this node is triggered. Has
## access to the initial [code]delta[/code] value.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var condition: String = "true"
@onready var condition_e: Expression = parse_expr(condition, ["delta"])

@export_group("Blackboard Output")

## Optional. Write the initial [code]delta[/code] value to this
## blackboard property. Not written if absent.
@export var initial_delta: StringName

## Optional. Write the [code]delta[/code] value [i]after[/i] applying
## the change via [property OnAlteredHealth.new_delta] to this
## blackboard property. Not written if absent.
@export var altered_delta: StringName

var done := false
var error := false

func deactivate() -> void:
	runner.health.unregister_modifier(_on_health_event)

func activate() -> void:
	runner.health.register_modifier(_on_health_event)
	done = false
	error = false

func load_state(_buffer: Array, idx: int, was_active: bool) -> int:
	if not was_active:
		activate()
	return idx

func physics_process_ability(_delta: float, first: bool) -> ARunResult:
	if first:
		activate()
	if error:
		return ARunResult.Error
	if done:
		return ARunResult.Done

	return ARunResult.Wait

func _on_health_event(delta: float) -> float:
	var cond_res := run_expr(condition, condition_e, [delta])
	if cond_res.err == Err.ShouldBail:
		error = true
		return delta

	if not cond_res.value:
		return delta

	var res := run_expr(new_delta, new_delta_e, [delta])
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not float):
		error = true
		return delta
	var altered_delta_value: float = res.value

	if initial_delta:
		blackboard.bset(initial_delta, delta)
	if altered_delta:
		blackboard.bset(altered_delta, altered_delta_value)

	if trigger() == ARunResult.Error:
		error = true

	done = not continuous
	return altered_delta_value
