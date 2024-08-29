class_name AbilityTriggered extends AbilityNode

func trigger() -> void:
	for i in get_child_count():
		var child: AbilityNode = get_child(i) as AbilityNode
		if ARunResult.Wait == child.physics_process_ability(0.0):
			push_error("Triggered ability did not finish immediately: " + str(child))
