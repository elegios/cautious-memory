## Run ability actions in sequence, one after the other, top to
## bottom. Interrupts only affect the currently executing child; if it
## gets interrupted this node also gets interrupted.
class_name AbilitySeq extends AbilityNode

var current_child: AbilityNode
var executing_idx: int:
	set(value):
		executing_idx = value
		if executing_idx < get_child_count():
			current_child = get_child(value) as AbilityNode
	get:
		return executing_idx

func _ready() -> void:
	current_child = get_child(executing_idx) as AbilityNode

func register_properties(root: AbilityRoot) -> void:
	root.register_prop(self, "executing_idx")

func process_ability(delta: float) -> ARunResult:
	while executing_idx < get_child_count():
		var res := current_child.process_ability(delta)
		if res == ARunResult.Done:
			executing_idx += 1
			continue
		else:
			return res
	return ARunResult.Done

func physics_process_ability(delta: float) -> ARunResult:
	while executing_idx < get_child_count():
		var res := current_child.physics_process_ability(delta)
		if res == ARunResult.Done:
			executing_idx += 1
			continue
		else:
			return res
	return ARunResult.Done

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	return current_child.interrupt(kind)
