@tool
## Move a character in a given direction.
class_name MoveCharacter extends AbilityNode

enum What { Direction, Point }

## How to interpret [member MoveCharacter.target]: as a direction or a
## point. A directional target keeps running forever, a positional
## target ends when the target has been reached.
@export var what: What = What.Direction

## A vector denoting the movement target. Either a direction to move
## in, in pixels per second, or a point to move to.
@export var target: String
@onready var target_e: Expression = parse_expr(target)

## A scaling factor/speed to be applied to the movement. Defaults to
## '1' if absent.
@export var speed: String
@onready var speed_e: Expression = parse_expr(speed) if speed else null

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"target", "speed":
			property.hint = PROPERTY_HINT_EXPRESSION

func physics_process_ability(delta: float) -> ARunResult:
	var vec: Vector2 = run_expr(target, target_e)
	var scale: float = run_expr(speed, speed_e) if speed_e else 1.0
	match what:
		What.Direction:
			runner.character.velocity = scale * vec
			var _hit := runner.character.move_and_slide()
			return ARunResult.Wait
		What.Point:
			if runner.character.position.is_equal_approx(vec):
				return ARunResult.Done
			var dir := vec - runner.character.position
			var distance := dir.length()
			dir = dir / distance
			runner.character.velocity = dir * (min(scale * delta, distance) / delta)
			var _hit := runner.character.move_and_slide()
			if runner.character.position.is_equal_approx(vec):
				return ARunResult.Done
			else:
				return ARunResult.Wait
		_:
			push_error("Bad 'What' in MoveCharacter")
			return ARunResult.Done
