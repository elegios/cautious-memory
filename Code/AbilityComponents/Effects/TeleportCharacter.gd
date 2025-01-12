@icon("../Icons/Character.svg")
## Instantly change the position of a character, possibly
## continuously.
class_name TeleportCharacter extends AbilityNode

## Continuously update character position. Finishes after the first
## position update if false, otherwise keeps updating position until
## interrupted.
@export var continuous: bool = false

## Position to set the character to.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var position: String
@onready var position_e: Expression = parse_expr(position)

func physics_process_ability(_delta: float, _first: bool) -> ARunResult:
	var res := run_expr(position, position_e)
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not Vector2):
		return ARunResult.Error
	runner.character.position = res.value
	return ARunResult.Wait if continuous else ARunResult.Done
