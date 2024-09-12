@tool
## Wait for an amount of time, then finish
class_name AbilityTimer extends AbilityNode

## The duration to wait in seconds.
@export var duration: String
@onready var duration_e: Expression = parse_expr(duration)
var elapsed: float = 0.0

@export_group("Blackboard Output")

## Optional. The curve used to convert between the fraction of time
## elapsed (0 to 1, on the x-axis) to the value to write (the
## y-axis). Defaults to 1-to-1 if absent.
@export var curve: Curve

@export var property: StringName

func _validate_property(prop: Dictionary) -> void:
	match prop.name:
		"duration":
			prop.hint = PROPERTY_HINT_EXPRESSION

func save_state(buffer: Array) -> void:
	buffer.push_back(elapsed)

func load_state(buffer: Array, idx: int) -> int:
	elapsed = buffer[idx]
	return idx + 1

func pre_first_process() -> void:
	elapsed = 0.0

func physics_process_ability(delta: float) -> ARunResult:
	elapsed += delta
	var limit: float = run_expr(duration, duration_e)

	if property:
		var fraction := clampf(elapsed / limit, 0.0, 1.0)
		blackboard.bset(property, curve.sample(fraction) if curve else fraction)

	if elapsed >= limit:
		return ARunResult.Done

	return ARunResult.Wait
