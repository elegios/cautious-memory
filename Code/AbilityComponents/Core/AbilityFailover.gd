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

func load_state(buffer: Array, idx: int) -> int:
	var new_idx: int = buffer[idx]
	idx += 1
	if executing_idx != new_idx:
		# if current_child:
		# 	current_child.sync_lost()
		executing_idx = new_idx
		idx = current_child.load_state(buffer, idx)
		# current_child.sync_gained()
	else:
		idx = current_child.load_state(buffer, idx)
	return idx

func transition(kind: TKind, dir: TDir) -> ARunResult:
	var forward := dir == TDir.Forward
	match kind:
		TKind.Enter:
			executing_idx = -1 if forward else get_child_count()
		TKind.Exit:
			# NOTE(vipa, 2024-10-28): When exiting forwards we assume
			# that the execution of the current node succeeded, thus
			# we do not [code]Skip[/code] the others.
			var end := executing_idx if forward else -1
			var step := 1 if forward else -1
			var _ignore := current_child.transition(TKind.Exit, dir)
			for idx in range(executing_idx + step, end, step):
				var c : AbilityNode = get_child(idx)
				_ignore = c.transition(TKind.Skip, dir)
		TKind.Skip:
			var c : AbilityNode = get_child(0)
			var _ignore := c.transition(TKind.Skip, dir)
	return super(kind, dir)

func sync_lost() -> void:
	# if current_child:
	# 	current_child.sync_lost()
	executing_idx = -1

func pre_first_process() -> void:
	executing_idx = 0
	# if current_child:
	# 	current_child.pre_first_process()

func physics_process_ability(delta: float) -> ARunResult:
	# var first := false
	while executing_idx < get_child_count():
		# if first:
		# 	current_child.pre_first_process()
		var res := current_child.physics_process_ability(delta)
		match res:
			ARunResult.Done:
				return ARunResult.Done
			ARunResult.Error:
				executing_idx += 1
				# first = true
				continue
			ARunResult.Wait:
				return ARunResult.Wait
	return ARunResult.Error

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var child := current_child
	if child:
		return child.interrupt(kind)
	return AInterruptResult.Interrupted
