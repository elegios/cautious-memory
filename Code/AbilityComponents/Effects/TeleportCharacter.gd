@icon("../Icons/Character.svg")
@tool
## Instantly change the position of a character, possibly
## continuously.
class_name TeleportCharacter extends AbilityNode

## Continuously update character position. Finishes after the first
## position update if false, otherwise keeps updating position until
## interrupted.
@export var continuous: bool = false

## Position to set the character to.
@export var position: String
@onready var position_e: Expression = parse_expr(position)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"position":
			property.hint = PROPERTY_HINT_EXPRESSION

func physics_process_ability(_delta: float) -> ARunResult:
	var res := run_expr(position, position_e)
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not Vector2):
		return ARunResult.Error
	runner.character.position = res.value
	return ARunResult.Wait if continuous else ARunResult.Done
