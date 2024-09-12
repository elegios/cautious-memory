@tool
## Like [AbilitySeq], but finish immediately if condition does not
## hold.
class_name Conditional extends AbilitySeq

## Keep checking the condition, interrupt children if it turns
## false. If not set, the condition is only checked once, before
## executing the first child.
@export var continuous: bool = false
## The condition to check.
@export var condition: String
@onready var condition_e: Expression = parse_expr(condition)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"condition":
			property.hint = PROPERTY_HINT_EXPRESSION

var checked: bool = false

func physics_process_ability(delta: float) -> ARunResult:
	if not checked:
		if run_expr(condition, condition_e):
			checked = not continuous
		else:
			var c := current_child
			if c:
				var _ignore := c.interrupt(AInterruptKind.Hard)
			return ARunResult.Done
	return super(delta)
