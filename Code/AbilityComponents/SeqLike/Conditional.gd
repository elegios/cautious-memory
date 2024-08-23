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

func setup(a: AbilityRunner, r: AbilityRoot, b: Dictionary, register_props: bool) -> void:
	condition.setup(a, b)
	super(a, r, b, register_props)

func register_properties(root: AbilityRoot) -> void:
	root.register_prop(self, "checked")
	super(root)

func process_ability(delta: float) -> ARunResult:
	if not checked:
		if condition.get_data(0.0):
			checked = not continuous
		else:
			var _ignore := current_child.interrupt(AInterruptKind.Hard)
			return ARunResult.Done
	return super(delta)

func physics_process_ability(delta: float) -> ARunResult:
	if not checked:
		if condition.get_data(delta):
			checked = not continuous
		else:
			var _ignore := current_child.interrupt(AInterruptKind.Hard)
			return ARunResult.Done
	return super(delta)
