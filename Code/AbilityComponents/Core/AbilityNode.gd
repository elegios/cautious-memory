## Base class for nodes that make up abilities. Should not appear
## directly, only through subclasses.
class_name AbilityNode extends Node

enum ARunResult {
	Wait,
	Done,
}
enum AInterruptKind {
	Hard,    # Hard interrupt, *must* return `Interrupted`
	Counter, # Gameplay interrupt abilities
	Soft,    # Other commands by player
}
enum AInterruptResult {
	Interrupted,   # The node was interrupted and should not continue running
	Uninterrupted  # The node was protected, it should keep running
}

var runner: AbilityRunner
var blackboard: Dictionary

func setup(a: AbilityRunner, b: Dictionary) -> void:
	runner = a
	blackboard = b
	for i in get_child_count():
		var c := get_child(i) as AbilityNode
		if c:
			c.setup(a, b)

## Encode node state in an array, to be sent to other clients when
## syncing execution status
func save_state(_buffer: Array) -> void:
	pass

## Inverse of [method AbilityNode.save_state], should restore state
## and possibly call [method AbilityNode.sync_lost] and [method
## AbilityNode.sync_gained] on children.
func load_state(_buffer: Array, idx: int) -> int:
	return idx

## Called by parent node if the local ability was executing this node,
## but the sync stated that it should not be executing. Should
## recursively call itself in children and perform any required
## cleanup.
func sync_lost() -> void:
	pass

## Called by parent node if the local ability was not executing this
## node, but the sync stated that it should be executing. Should
## perform any required setup. Always called [i]after[/i] a
## corresponding [method AbilityNode.load_state] call. This method
## typically doesn't need to recursively call itself in children,
## because the corresponding [method AbilityNode.load_state] should
## typically perform such calls as needed.
func sync_gained() -> void:
	pass

func pre_first_process() -> void:
	pass

func physics_process_ability(_delta: float) -> ARunResult:
	return ARunResult.Wait

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	match kind:
		AInterruptKind.Hard, AInterruptKind.Counter:
			return AInterruptResult.Interrupted
		AInterruptKind.Soft:
			return AInterruptResult.Uninterrupted
		_:
			assert(false, "Impossible")
			return AInterruptResult.Interrupted
