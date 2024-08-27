## Wait for an amount of time, then finish
class_name AbilityTimer extends AbilityNode

## The duration to wait in seconds.
@export var duration: DataSource
var elapsed: float = 0.0

func setup(a: AbilityRunner, r: AbilityRoot, b: Dictionary, register_props: bool) -> void:
	duration = duration.setup(a, b)
	super(a, r, b, register_props)

func register_properties(root: AbilityRoot) -> void:
	root.register_prop(self, "elapsed")
	duration.register_properties(self, "duration", root)

func physics_process_ability(delta: float) -> ARunResult:
	elapsed += delta
	var limit: float = duration.get_data(delta)
	if elapsed >= limit:
		return ARunResult.Done
	return ARunResult.Wait
