## Try running children, one at a time, until one completes
## successfully. Used to catch and recover from errors.
class_name AbilityFailover extends AbilityNode


# TODO(vipa, 2024-10-28): The synchronization of this node is tricky,
# because we don't have a good way of keeping track of which nodes
# were executed locally and/or remotely, so we don't know which ones
# to run [code]transition[/code] for. Leaving it incomplete for now,
# and I'll try to figure something out if we actually need the node.

var executing_idx: int = -1

var current_child: AbilityNode:
	get:
		if 0 <= executing_idx and executing_idx < get_child_count():
			return get_child(executing_idx) as AbilityNode
		return null

func save_state(buffer: Array) -> void:
	buffer.push_back(executing_idx)
	current_child.save_state(buffer)

func deactivate() -> void:
	if current_child:
		current_child.deactivate()
	executing_idx = -1

func load_state(buffer: Array, idx: int, _was_active: bool) -> int:
	var new_idx : int = buffer[idx]
	idx += 1
	if executing_idx != new_idx and current_child:
		current_child.deactivate()
	var was_active := executing_idx == new_idx
	executing_idx = new_idx
	idx = current_child.load_state(buffer, idx, was_active)
	return idx

func physics_process_ability(delta: float, first: bool) -> ARunResult:
	if first:
		executing_idx = 0

	while executing_idx < get_child_count():
		var child := current_child
		var res := child.physics_process_ability(delta, first)
		match res:
			ARunResult.Done:
				child.deactivate()
				return ARunResult.Done
			ARunResult.Error:
				child.deactivate()
				executing_idx += 1
				first = true
				continue
			ARunResult.Wait:
				return ARunResult.Wait
	return ARunResult.Error

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var child := current_child
	if child:
		var res := child.interrupt(kind)
		if res == AInterruptResult.Interrupted:
			child.deactivate()
		return res
	return AInterruptResult.Interrupted
