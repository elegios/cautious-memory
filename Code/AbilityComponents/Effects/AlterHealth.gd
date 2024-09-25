@tool
## Change the health of a unit.
class_name AlterHealth extends AbilityNode

## The target to affect. Defaults to the current character if absent.
@export var target: String
@onready var target_e: Expression = parse_expr(target) if target else null

## The amount to change the health by. Negative means damage, positive
## means healing.
@export var amount: String
@onready var amount_e: Expression = parse_expr(amount)

@export_group("Blackboard Output")

## Optional. Save the actual amount by which the target's health
## changed to this blackboard property. Not saved if empty.
@export var actual_amount: StringName

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"target", "amount":
			property.hint = PROPERTY_HINT_EXPRESSION

func physics_process_ability(_delta: float) -> ARunResult:
	var t: Node = run_expr(target, target_e) if target_e else runner.character
	var a: float = run_expr(amount, amount_e)

	for c_i in t.get_child_count():
		var health := t.get_child(c_i) as Health
		if health:
			var diff := health.alter_health(a)
			if actual_amount:
				blackboard.bset(actual_amount, diff)
			return ARunResult.Done

	push_warning("The target didn't have a Health component\ntarget: %s" % [t.get_path()])
	return ARunResult.Done
