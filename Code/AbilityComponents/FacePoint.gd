class_name FacePoint extends AbilityNode

@export var continuous: bool = false

@export var point: DataSource

func setup(a: AbilityRunner, b: Dictionary) -> void:
	point = point.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	point.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	return point.load_state(buffer, idx)

func pre_first_process() -> void:
	point.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	var v_point: Vector2 = point.get_data(delta)
	runner.character.rotation = runner.character.position.angle_to_point(v_point)
	return ARunResult.Wait if continuous else ARunResult.Done
