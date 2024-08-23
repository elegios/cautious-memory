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
	for i in children.size():
		executing_idxes |= 1 << i

func register_properties(root: AbilityRoot) -> void:
	root.register_prop(self, "executing_idxes")

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
