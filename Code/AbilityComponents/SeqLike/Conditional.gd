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

func setup(a: AbilityRunner, b: Dictionary) -> void:
	condition = condition.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	condition.save_state(buffer)
	super(buffer)

func load_state(buffer: Array, idx: int) -> int:
	idx = condition.load_state(buffer, idx)
	return super(buffer, idx)

func pre_first_process() -> void:
	condition.pre_first_data()
	super()

func process_ability(delta: float) -> ARunResult:
	if not checked:
		if condition.get_data(0.0):
			checked = not continuous
		else:
			var c := current_child
			if c:
				var _ignore := c.interrupt(AInterruptKind.Hard)
			return ARunResult.Done
	return super(delta)

func physics_process_ability(delta: float) -> ARunResult:
	if not checked:
		if condition.get_data(delta):
			checked = not continuous
		else:
			var c := current_child
			if c:
				var _ignore := c.interrupt(AInterruptKind.Hard)
			return ARunResult.Done
	return super(delta)
