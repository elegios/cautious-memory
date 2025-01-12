## Change the [i]visual[/i] position of a unit without impacting the
## true location.
class_name VisualOffset extends AbilityNode

enum What { Relative, Absolute }

## How to position the unit. "Relative" means relative to the actual
## position, "absolute" means actual coordinates in the world.
@export var positioning := What.Relative

## The [i]visual[/i] position of the unit.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var target: String
@onready var target_e: Expression = parse_expr(target)

func deactivate() -> void:
	runner.visual_offset.position = Vector2.ZERO

func physics_process_ability(_delta: float, _first: bool) -> ARunResult:
	var res := run_expr(target, target_e)
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not Vector2):
		return ARunResult.Error
	var pos : Vector2 = res.value

	match positioning:
		What.Relative:
			runner.visual_offset.position = pos
		What.Absolute:
			runner.visual_offset.global_position = pos

	return ARunResult.Wait
