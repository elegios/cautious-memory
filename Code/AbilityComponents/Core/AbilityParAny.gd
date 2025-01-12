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

func deactivate() -> void:
	for i in children.size():
		if ((1 << i) & executing_idxes):
			children[i].deactivate()
	executing_idxes = 0

func load_state(buffer: Array, idx: int, _was_active: bool) -> int:
	var synced_idxes: int = buffer[idx]
	idx += 1
	for i in children.size():
		var was_executing := ((1 << i) & executing_idxes)
		var is_executing := ((1 << i) & synced_idxes)
		if is_executing:
			idx = children[i].load_state(buffer, idx, was_executing)
		elif was_executing:
			children[i].deactivate()
	executing_idxes = synced_idxes
	return idx

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
				send_interrupts()
				return ARunResult.Done
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

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		match children[i].interrupt(kind):
			AInterruptResult.Interrupted:
				children[i].deactivate()
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
		children[i].deactivate()
	executing_idxes = 0
