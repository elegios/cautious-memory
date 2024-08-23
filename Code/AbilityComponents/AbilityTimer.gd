## Wait for an amount of time, then finish
class_name AbilityTimer extends AbilityNode

## The duration to wait in seconds.
@export var duration: DataSource
var elapsed: float = 0.0

func register_properties(root: AbilityRoot) -> void:
	root.register_prop(self, "elapsed")

func physics_process_ability(delta: float) -> ARunResult:
	elapsed += delta
	var limit: float = duration.get_data(player, blackboard)
	if elapsed >= limit:
		return ARunResult.Done
	return ARunResult.Wait
