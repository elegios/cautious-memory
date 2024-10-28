@icon("../Icons/Condition.svg")
## Like [AbilitySeq], but finish immediately if condition does not
## hold.
class_name Conditional extends AbilitySeq

## The condition to check.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var condition: String
@onready var condition_e: Expression = parse_expr(condition)

var checked: bool = false

func transition(kind: TKind, dir: TDir) -> ARunResult:
	if dir == TDir.Backward or kind == TKind.Exit:
		return super(kind, dir)

	var res := run_expr(condition, condition_e)
	if res.err == Err.ShouldBail:
		return ARunResult.Error
	if res.value:
		return super(kind, dir)

	return ARunResult.Done
