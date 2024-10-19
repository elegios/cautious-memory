class_name MobAbilityScript extends AbilityScript

## Whether the ability should be a main ability. If true, requires the
## current main ability (if any) to acknowledge a soft
## interrupt. Always succeeds if false.
func _is_main() -> bool:
	return true

@export var cooldown := 2.0

## The cooldown of this ability, in seconds.
func _cooldown() -> float:
	return cooldown

## The condition that must hold for this ability to be used.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var condition: String
var condition_e : Expression:
	get:
		if condition_e:
			return condition_e
		condition_e = parse_expr(condition)
		return condition_e

func check_condition(runner: AbilityRunner) -> bool:
	var res := run_expr(runner, condition, condition_e)
	if not res.value or res.err & AbilityNode.Err.ShouldBail:
		return false
	return true

# NOTE(vipa, 2024-09-12): This function and the next are very similar
# to corresponding ones in MobAbilities. They should either be kept in
# sync or extracted somewhere.
func parse_expr(text: String) -> Expression:
	var e := Expression.new()
	var res := e.parse(text, ["character", "bb"])
	if res != OK:
		print(error_string(res))
		push_error("Error: %s\npath: %s\nexpr: %s" % [e.get_error_text(), get_path(), text])
	return e

func run_expr(runner: AbilityRunner, text: String, e: Expression) -> AbilityNode.ExprRes:
	runner.unit_local.errs = Blackboard.Err.None
	var res: Variant = e.execute([runner.character, runner.unit_local], null, false, true)

	if e.has_execute_failed():
		if runner.unit_local.errs & Blackboard.Err.MissingUnit:
			return AbilityNode.ExprRes.new(res, AbilityNode.Err.ShouldBail)
		assert(false, "Error: %s\npath: %s\nexpr: %s\nunit_local: %s" % [e.get_error_text(), get_path(), text, runner.unit_local])

	if runner.unit_local.errs & Blackboard.Err.MissingUnit:
		return AbilityNode.ExprRes.new(res, AbilityNode.Err.MightBail)

	return AbilityNode.ExprRes.new(res, AbilityNode.Err.None)
