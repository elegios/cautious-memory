@icon("../Icons/Character.svg")
## Rotate the character. Note that this is different from setting the
## direction to face on sprites with multiple directions.
class_name RotateCharacter extends AbilityNode

## Keep rotating forever (or until interrupted)
@export var continuous: bool = false

## Target to face. Can be a target (Vector2) or an angle (float, in
## radians)
@export_custom(PROPERTY_HINT_EXPRESSION, "") var target: String
@onready var target_e: Expression = parse_expr(target)

func physics_process_ability(_delta: float) -> ARunResult:
	var res := run_expr(target, target_e)
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not Vector2 and res.value is not float):
		return ARunResult.Error
	if res.value is Vector2:
		var v_target: Vector2 = res.value
		runner.character.rotation = runner.character.position.angle_to_point(v_target)
	elif res.value is float:
		var v_angle: float = res.value
		runner.character.rotation = v_angle
	return ARunResult.Wait if continuous else ARunResult.Done
