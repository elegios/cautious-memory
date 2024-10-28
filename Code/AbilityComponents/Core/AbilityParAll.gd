@icon("../Icons/ParAll.svg")
## Run a number of actions in parallel, waiting until all have
## finished. Interrupts are propagated to running children,
## potentially interrupting them. This node gets interrupted if no
## running children remain afterwards.
class_name AbilityParAll extends AbilityParAny

func physics_process_ability(delta: float) -> ARunResult:
	if not has_started:
		has_started = true
		executing_idxes = (1 << children.size()) - 1
		for i in children.size():
			match children[i].transition(TKind.Enter, TDir.Forward):
				ARunResult.Done:
					var _ignore := children[i].transition(TKind.Exit, TDir.Forward)
					executing_idxes &= ~(1 << i)
				ARunResult.Wait:
					pass
				ARunResult.Error:
					var _ignore := children[i].transition(TKind.Exit, TDir.Forward)
					# NOTE(vipa, 2024-10-28): Turn off executing for
					# the later idxes, since we haven't gotten there
					# yet, as well as the current one, since we've
					# already run the exit transition for it
					executing_idxes &= (1 << i) - 1
					send_interrupts()
					return ARunResult.Error

	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		match children[i].physics_process_ability(delta):
			ARunResult.Done:
				var _ignore := children[i].transition(TKind.Exit, TDir.Forward)
				executing_idxes &= ~(1 << i)
			ARunResult.Error:
				var _ignore := children[i].transition(TKind.Exit, TDir.Forward)
				executing_idxes &= ~(1 << i)
				send_interrupts()
				return ARunResult.Error
			ARunResult.Wait:
				pass
	if executing_idxes:
		return ARunResult.Wait
	return ARunResult.Done
