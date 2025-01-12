@icon("../Icons/Seq.svg")
## Run ability actions in sequence, one after the other, top to
## bottom. Interrupts only affect the currently executing child; if it
## gets interrupted this node also gets interrupted.
class_name AbilitySeq extends AbilityNode

var executing_idx: int = -1

var current_child: AbilityNode:
	get:
		if 0 <= executing_idx and executing_idx < get_child_count():
			return get_child(executing_idx) as AbilityNode
		return null

func save_state(buffer: Array) -> void:
	buffer.push_back(executing_idx)
	if current_child:
		current_child.save_state(buffer)

func deactivate() -> void:
	if current_child:
		current_child.deactivate()
	executing_idx = -1

func load_state(buffer: Array, idx: int, _was_active: bool) -> int:
	var new_idx: int = buffer[idx]
	idx += 1
	var was_active := executing_idx == new_idx
	if executing_idx != new_idx and current_child:
		current_child.deactivate()
	executing_idx = new_idx
	idx = current_child.load_state(buffer, idx, was_active)
	return idx

func physics_process_ability(delta: float, first: bool) -> ARunResult:
	if first:
		executing_idx = 0

	while executing_idx < get_child_count():
		match current_child.physics_process_ability(delta, first):
			ARunResult.Done:
				current_child.deactivate()
				executing_idx += 1
				first = true
				continue
			ARunResult.Wait:
				return ARunResult.Wait
			ARunResult.Error:
				current_child.deactivate()
				return ARunResult.Error

	return ARunResult.Done

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var child := current_child
	if child:
		var res := child.interrupt(kind)
		if res == AInterruptResult.Interrupted:
			child.deactivate()
			executing_idx = -1
		return res
	return AInterruptResult.Interrupted
