@icon("../Icons/ParOne.svg")
## Run a number of actions in parallel until one finishes, then
## interrupt the others. Interrupts are propagated to running
## children, potentially interrupting them. This node gets interrupted
## if no running children remain afterwards.
class_name AbilityParAny extends AbilityNode

# NOTE(vipa, 2024-08-19): This is essentially the same class as
# AbilityParAll, except it only waits for *one* child to finish, then
# interrupts the rest and returns with Done. A change in one probably
# means the other should change as well.

var children: Array[AbilityNode]

## A bit-mask of children that are currently running. This is needed
## despite aborting as soon as one child finishes, since we could have
## a partial interrupt.
var executing_idxes: int = 0
## Whether the current node has started
var has_started := false

func _ready() -> void:
	children = []
	for i in get_child_count():
		children.append(get_child(i) as AbilityNode)

func save_state(buffer: Array) -> void:
	buffer.push_back(executing_idxes)
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		children[i].save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	var synced_idxes: int = buffer[idx]
	idx += 1
	var enter_dir := TDir.Backward if has_started else TDir.Forward
	for i in children.size():
		var was_executing := ((1 << i) & executing_idxes)
		var is_executing := ((1 << i) & synced_idxes)
		if is_executing:
			if not was_executing:
				var _ignore := children[i].transition(TKind.Enter, enter_dir)
			idx = children[i].load_state(buffer, idx)
		if not has_started and not is_executing:
			var _ignore := children[i].transition(TKind.Skip, TDir.Forward)
	executing_idxes = synced_idxes
	has_started = true
	return idx

func transition(kind: TKind, dir: TDir) -> ARunResult:
	var forward := dir == TDir.Forward
	match kind:
		TKind.Enter:
			executing_idxes = 0
			has_started = not forward
		TKind.Exit:
			var r := range(0, children.size(), 1) if forward else range(children.size()-1, -1, -1)
			for i: int in r:
				if not ((1 << i) & executing_idxes):
					continue
				var _ignore := children[i].transition(TKind.Exit, dir)
			if dir == TDir.Backward:
				for i: int in r:
					if ((1 << i) & executing_idxes):
						continue
					var _ignore := children[i].transition(TKind.Skip, TDir.Backward)
			executing_idxes = 0
			has_started = true
		TKind.Skip:
			for i: int in range(0, children.size(), 1) if forward else range(children.size()-1, -1, -1):
				var _ignore := children[i].transition(TKind.Skip, dir)
			executing_idxes = 0
			has_started = forward
	return super(kind, dir)

func physics_process_ability(delta: float) -> ARunResult:
	if not has_started:
		has_started = true
		executing_idxes = (1 << children.size()) - 1
		for i in children.size():
			match children[i].transition(TKind.Enter, TDir.Forward):
				ARunResult.Done:
					var _ignore := children[i].transition(TKind.Exit, TDir.Forward)
					# NOTE(vipa, 2024-10-28): Turn off executing for
					# the later idxes, since we haven't gotten there
					# yet, as well as the current one, since we've
					# already run the exit transition for it
					executing_idxes &= (1 << i) - 1
					send_interrupts()
					return ARunResult.Done
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
				send_interrupts()
				return ARunResult.Done
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

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		match children[i].interrupt(kind):
			AInterruptResult.Interrupted:
				var _ignore := children[i].transition(TKind.Exit, TDir.Forward)
				executing_idxes &= ~(1 << i)
			AInterruptResult.Uninterrupted:
				pass
	if executing_idxes:
		return AInterruptResult.Uninterrupted
	return AInterruptResult.Interrupted

func send_interrupts() -> void:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		var _ignore := children[i].interrupt(AInterruptKind.Hard)
		var _ignore_res := children[i].transition(TKind.Exit, TDir.Forward)
	executing_idxes = 0
