@icon("../Icons/Condition.svg")
## Like [AbilitySeq], but finish immediately if condition does not
## hold.
class_name Conditional extends AbilitySeq

## The condition to check.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var condition: String
@onready var condition_e: Expression = parse_expr(condition)

## If true, check the condition every frame, interrupt children if
## it's ever false. If false, only check once, when we enter this
## node.
@export var continuous: bool = false

func physics_process_ability(delta: float, first: bool) -> ARunResult:
	if continuous or first:
		var res := run_expr(condition, condition_e)
		if res.err == Err.ShouldBail:
			return ARunResult.Error
		if not res.value:
			if current_child:
				current_child.deactivate()
			return ARunResult.Done
	return super(delta, first)
