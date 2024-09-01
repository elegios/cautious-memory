class_name RotateCharacter extends AbilityNode

## Keep rotating forever (or until interrupted)
@export var continuous: bool = false

## Target to face. Can be a target (Vector2) or an angle (float, in
## radians)
@export var target: DataSource

func setup(a: AbilityRunner, b: Dictionary) -> void:
	target = target.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	target.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	return target.load_state(buffer, idx)

func pre_first_process() -> void:
	target.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	var variant: Variant = target.get_data(delta)
	if variant is Vector2:
		var v_target: Vector2 = variant
		runner.character.rotation = runner.character.position.angle_to_point(v_target)
	elif variant is float:
		var v_angle: float = variant
		runner.character.rotation = v_angle
	return ARunResult.Wait if continuous else ARunResult.Done
