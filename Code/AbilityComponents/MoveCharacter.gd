## Move a character in a given direction.
class_name MoveCharacter extends AbilityNode

enum What { Direction, Point }

## How to interpret [member MoveCharacter.target]: as a direction or a
## point. A directional target keeps running forever, a positional
## target ends when the target has been reached.
@export var what: What = What.Direction

## A vector denoting the movement target. Either a direction to move
## in, in pixels per second, or a point to move to.
@export var target: DataSource

## A scaling factor/speed to be applied to the movement. Defaults to
## '1' if absent.
@export var speed: DataSource

func setup(a: AbilityRunner, b: Dictionary) -> void:
	target = target.setup(a, b)
	if speed:
		speed = speed.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	target.save_state(buffer)
	if speed:
		speed.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	idx = target.load_state(buffer, idx)
	if speed:
		idx = speed.load_state(buffer, idx)
	return idx

func pre_first_process() -> void:
	target.pre_first_data()
	if speed:
		speed.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	var vec: Vector2 = target.get_data(delta)
	var scale: float = speed.get_data(delta) if speed else 1.0
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
