## Wait for an amount of time, then finish
class_name AbilityTimer extends AbilityNode

## The duration to wait in seconds.
@export var duration: DataSource
var elapsed: float = 0.0

func setup(a: AbilityRunner, b: Dictionary) -> void:
	duration = duration.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	buffer.push_back(elapsed)
	duration.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	elapsed = buffer[idx]
	return duration.load_state(buffer, idx + 1)

func pre_first_process() -> void:
	elapsed = 0.0
	duration.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	elapsed += delta
	var limit: float = duration.get_data(delta)
	if elapsed >= limit:
		return ARunResult.Done
	return ARunResult.Wait
