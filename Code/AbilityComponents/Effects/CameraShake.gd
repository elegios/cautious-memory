class_name CameraShake extends AbilityNode

## The position at which the shake originates. Defaults to the
## character position.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var center_position: String
@onready var center_position_e: Expression = parse_expr(center_position) if center_position else null

## The strength of the shake.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var shake_strength: String
@onready var shake_strength_e: Expression = parse_expr(shake_strength)

func physics_process_ability(_delta: float) -> ARunResult:
	var pos := run_expr(center_position, center_position_e) if center_position_e else ExprRes.new(runner.character.position)
	if pos.err == Err.ShouldBail or (pos.err == Err.MightBail and pos.value is not Vector2):
		return ARunResult.Error
	var p : Vector2 = pos.value

	var strength := run_expr(shake_strength, shake_strength_e)
	if strength.err == Err.ShouldBail or (pos.err == Err.MightBail and pos.value is not float):
		return ARunResult.Error
	var s : float = strength.value

	PlayerCamera.add_shake(p, s)

	return ARunResult.Done
