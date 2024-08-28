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

# A bit-mask of children that are currently running. This is needed
# despite aborting as soon as one child finishes, since we could have
# a partial interrupt.
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

func load_state(buffer: Array, idx: int) -> int:
	var synced_idxes: int = buffer[idx]
	idx += 1
	for i in children.size():
		var was_executing := ((1 << i) & executing_idxes)
		var is_executing := ((1 << i) & synced_idxes)
		if is_executing:
			idx = children[i].load_state(buffer, idx)
			if not was_executing:
				children[i].sync_gained()
		if was_executing and not is_executing:
			children[i].sync_lost()
	executing_idxes = synced_idxes
	return idx

func sync_gained() -> void:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		children[i].sync_gained()

func sync_lost() -> void:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		children[i].sync_lost()
	executing_idxes = 0

func pre_first_process() -> void:
	executing_idxes = (1 << children.size()) - 1
	for c in children:
		c.pre_first_process()

func process_ability(delta: float) -> ARunResult:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		match children[i].process_ability(delta):
			ARunResult.Done:
				executing_idxes = executing_idxes & ~(1 << i)
				send_interrupts()
				return ARunResult.Done
			ARunResult.Wait:
				continue
	return ARunResult.Wait

func physics_process_ability(delta: float) -> ARunResult:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		match children[i].physics_process_ability(delta):
			ARunResult.Done:
				executing_idxes = executing_idxes & ~(1 << i)
				send_interrupts()
				return ARunResult.Done
			ARunResult.Wait:
				continue
	return ARunResult.Wait

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	for i in children.size():
		if not ((1 << i) & executing_idxes):
			continue
		match children[i].interrupt(kind):
			AInterruptResult.Interrupted:
				executing_idxes = executing_idxes & ~(1 << i)
			AInterruptResult.Uninterrupted:
				pass
	if executing_idxes:
		return AInterruptResult.Uninterrupted
	return AInterruptResult.Interrupted

func send_interrupts() -> void:
	for i in children.size():
		if 0 == ((1 << i) & executing_idxes):
			continue
		var _ignore := children[i].interrupt(AInterruptKind.Hard)
