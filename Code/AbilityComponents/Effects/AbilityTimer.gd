@icon("../Icons/Timer.svg")
## Wait for an amount of time, then finish
class_name AbilityTimer extends AbilityNode

## The duration to wait in seconds.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var duration: String
@onready var duration_e: Expression = parse_expr(duration)
var elapsed: float = 0.0

@export_group("Blackboard Output")

## Optional. The curve used to convert between the fraction of time
## elapsed (0 to 1, on the x-axis) to the value to write (the
## y-axis). Defaults to 1-to-1 if absent.
@export var curve: Curve

@export var property: StringName

func save_state(buffer: Array) -> void:
	buffer.push_back(elapsed)

func load_state(buffer: Array, idx: int) -> int:
	elapsed = buffer[idx]
	return idx + 1

func pre_first_process() -> void:
	elapsed = 0.0

func physics_process_ability(delta: float) -> ARunResult:
	elapsed += delta
	var res := run_expr(duration, duration_e)
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not float):
		return ARunResult.Error
	var limit: float = res.value

	if property:
		var fraction := clampf(elapsed / limit, 0.0, 1.0)
		blackboard.bset(property, curve.sample(fraction) if curve else fraction)

	if elapsed >= limit:
		return ARunResult.Done

	return ARunResult.Wait
