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

func load_state(buffer: Array, idx: int) -> int:
	var new_idx: int = buffer[idx]
	idx += 1
	if executing_idx != new_idx:
		var dir := TDir.Forward if new_idx > executing_idx else TDir.Backward
		var step := 1 if new_idx > executing_idx else -1
		var _ignore : ARunResult
		if current_child:
			_ignore = current_child.transition(TKind.Exit, dir)
		executing_idx += step
		while executing_idx != new_idx:
			_ignore = current_child.transition(TKind.Skip, dir)
			executing_idx += step
		_ignore = current_child.transition(TKind.Enter, dir)
	idx = current_child.load_state(buffer, idx)
	return idx

func transition(kind: TKind, dir: TDir) -> ARunResult:
	var forward := dir == TDir.Forward
	match kind:
		TKind.Enter:
			executing_idx = -1 if forward else get_child_count()
		TKind.Exit:
			var end := get_child_count() if forward else -1
			var step := 1 if forward else -1
			if current_child:
				var _ignore := current_child.transition(TKind.Exit, dir)
			for idx in range(executing_idx + step, end, step):
				var c : AbilityNode = get_child(idx)
				var _ignore := c.transition(TKind.Skip, dir)
		TKind.Skip:
			var start := 0 if forward else get_child_count() - 1
			var end := get_child_count() if forward else -1
			var step := 1 if forward else -1
			for idx in range(start, end, step):
				var c : AbilityNode = get_child(idx)
				var _ignore := c.transition(TKind.Skip, dir)
	return super(kind, dir)


func physics_process_ability(delta: float) -> ARunResult:
	var first := false
	if executing_idx < 0:
		first = true
		executing_idx = 0

	while executing_idx < get_child_count():
		if first:
			match current_child.transition(TKind.Enter, TDir.Forward):
				ARunResult.Done:
					var _ignore := current_child.transition(TKind.Exit, TDir.Forward)
					executing_idx += 1
					first = true
					continue
				ARunResult.Wait:
					pass
				ARunResult.Error:
					var _ignore := current_child.transition(TKind.Exit, TDir.Forward)
					return ARunResult.Error

		match current_child.physics_process_ability(delta):
			ARunResult.Done:
				var _ignore := current_child.transition(TKind.Exit, TDir.Forward)
				executing_idx += 1
				first = true
				continue
			ARunResult.Wait:
				return ARunResult.Wait
			ARunResult.Error:
				var _ignore := current_child.transition(TKind.Exit, TDir.Forward)
				return ARunResult.Error

	return ARunResult.Done

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var child := current_child
	if child:
		var res := child.interrupt(kind)
		if res == AInterruptResult.Interrupted:
			var _ignore := child.transition(TKind.Exit, TDir.Forward)
			executing_idx = get_child_count()
		return res
	return AInterruptResult.Interrupted
