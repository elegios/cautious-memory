class_name AbilityTriggered extends AbilityNode

## Run the child ability nodes in sequence, with the expectation that
## they finish immediately.
func trigger() -> ARunResult:
	for i in get_child_count():
		var child: AbilityNode = get_child(i)

		match child.physics_process_ability(0.0, true):
			ARunResult.Done:
				child.deactivate()
			ARunResult.Wait:
				assert(false, "Triggered ability did not finish immediately: " + str(child))
			ARunResult.Error:
				child.deactivate()
				return ARunResult.Error

	return ARunResult.Done
