## Move a character in a given direction.
class_name MoveCharacter extends AbilityNode

## A vector denoting the direction to move in, in pixels per
## second. Note that the vector will [i]not[/i] be normalized before
## being applied.
@export var direction: DataSource
## A scaling factor to be applied to the direction. Defaults to '1' if
## absent.
@export var factor: DataSource

func setup(a: AbilityRunner, r: AbilityRoot, b: Dictionary, register_props: bool) -> void:
	direction.setup(a, b)
	if factor:
		factor.setup(a, b)
	super(a, r, b, register_props)

func register_properties(root: AbilityRoot) -> void:
	direction.register_properties(self, "direction", root)
	if factor:
		factor.register_properties(self, "factor", root)

func physics_process_ability(delta: float) -> ARunResult:
	var dir: Vector2 = direction.get_data(delta)
	var scale: float = factor.get_data(delta) if factor else 1.0
	runner.character.velocity = scale * dir
	var _hit := runner.character.move_and_slide()
	return ARunResult.Wait
