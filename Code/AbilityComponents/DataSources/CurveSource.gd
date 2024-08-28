class_name CurveSource extends DataSource

@export var duration: float = 1.0
@export var curve: Curve

var elapsed: float = 0.0

func save_state(buffer: Array) -> void:
	buffer.push_back(elapsed)

func load_state(buffer: Array, idx: int) -> int:
	elapsed = buffer[idx]
	return idx + 1

func pre_first_data() -> void:
	elapsed = 0.0

func get_data(delta: float) -> Variant:
	elapsed += delta
	return curve.sample(elapsed / duration)
