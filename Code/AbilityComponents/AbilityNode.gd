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

var player: Player
var blackboard: Dictionary

func setup(p: Player, b: Dictionary) -> void:
	player = p
	blackboard = b
	for i in get_child_count():
		var c := get_child(i) as AbilityNode
		if c:
			c.setup(player, blackboard)

# Register properties that need to be synced for this node
func register_properties(_root: AbilityRoot) -> void:
	pass

func process_ability(_delta: float) -> ARunResult:
	return ARunResult.Wait

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
