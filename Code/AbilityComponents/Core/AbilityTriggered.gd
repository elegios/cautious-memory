class_name AbilityTriggered extends AbilityNode

## Run the child ability nodes in sequence, with the expectation that
## they finish immediately.
func trigger() -> void:
	for i in get_child_count():
		var child: AbilityNode = get_child(i) as AbilityNode
		if ARunResult.Wait == child.physics_process_ability(0.0):
			push_error("Triggered ability did not finish immediately: " + str(child))
