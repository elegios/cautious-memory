class_name AbilityTriggered extends AbilityNode

## Run the child ability nodes in sequence, with the expectation that
## they finish immediately.
func trigger() -> ARunResult:
	for i in get_child_count():
		var child: AbilityNode = get_child(i)

		match child.transition(TKind.Enter, TDir.Forward):
			ARunResult.Done:
				var _ignore := child.transition(TKind.Exit, TDir.Forward)
				continue
			ARunResult.Wait:
				pass
			ARunResult.Error:
				var _ignore := child.transition(TKind.Exit, TDir.Forward)
				return ARunResult.Error

		match child.physics_process_ability(0.0):
			ARunResult.Done:
				var _ignore := child.transition(TKind.Exit, TDir.Forward)
			ARunResult.Wait:
				assert(false, "Triggered ability did not finish immediately: " + str(child))
			ARunResult.Error:
				var _ignore := child.transition(TKind.Exit, TDir.Forward)
				return ARunResult.Error

	return ARunResult.Done
