## Like [AbilitySeq], but finish immediately if condition does not
## hold.
class_name Conditional extends AbilitySeq

## Keep checking the condition, interrupt children if it turns
## false. If not set, the condition is only checked once, before
## executing the first child.
@export var continuous: bool = false
## The condition to check.
@export var condition: DataSource

var checked: bool = false

func register_properties(root: AbilityRoot) -> void:
	root.register_prop(self, "checked")
	super(root)

func process_ability(delta: float, player: Player, blackboard: Dictionary) -> ARunResult:
	if not checked:
		if condition.get_data(player, blackboard):
			checked = not continuous
		else:
			var _ignore := current_child.interrupt(AInterruptKind.Hard)
			return ARunResult.Done
	return super(delta, player, blackboard)

func physics_process_ability(delta: float, player: Player, blackboard: Dictionary) -> ARunResult:
	if not checked:
		if condition.get_data(player, blackboard):
			checked = not continuous
		else:
			var _ignore := current_child.interrupt(AInterruptKind.Hard)
			return ARunResult.Done
	return super(delta, player, blackboard)
