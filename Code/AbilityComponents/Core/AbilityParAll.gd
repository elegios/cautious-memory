@icon("../Icons/ParAll.svg")
## Run a number of actions in parallel, waiting until all have
## finished. Interrupts are propagated to running children,
## potentially interrupting them. This node gets interrupted if no
## running children remain afterwards.
class_name AbilityParAll extends AbilityParAny

func physics_process_ability(delta: float, first: bool) -> ARunResult:
	if first:
		executing_idxes = (1 << children.size()) - 1

	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		match children[i].physics_process_ability(delta, first):
			ARunResult.Done:
				children[i].deactivate()
				executing_idxes &= ~(1 << i)
			ARunResult.Error:
				children[i].deactivate()
				executing_idxes &= ~(1 << i)
				send_interrupts()
				return ARunResult.Error
			ARunResult.Wait:
				pass
	if executing_idxes:
		return ARunResult.Wait
	return ARunResult.Done
