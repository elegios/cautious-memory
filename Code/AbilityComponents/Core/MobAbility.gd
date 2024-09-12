@tool
class_name MobAbility extends Resource

## Whether the ability should be a main ability. If true, requires the
## current main ability (if any) to acknowledge a soft
## interrupt. Always succeeds if false.
@export var is_main : bool = true

## The cooldown of this ability, in seconds.
@export var cooldown : float = 2.0

## Optional. All of these conditions must be true to run the
## ability. Short-circuiting, i.e., if the first condition fails, then
## the second isn't even checked.
@export var conditions : Array[String]:
	set(value):
		conditions = value
		conditions_e = []
		for t in conditions:
			conditions_e.push_back(parse_expr(t))
var conditions_e: Array[Expression]

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"conditions":
			property.hint = PROPERTY_HINT_EXPRESSION

## The ability to run.
@export var ability : PackedScene

func check_condition(runner: AbilityRunner) -> bool:
	for i in conditions_e.size():
		if not run_expr(runner, conditions[i], conditions_e[i]):
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

func run_expr(runner: AbilityRunner, text: String, e: Expression) -> Variant:
	var res: Variant = e.execute([runner.character, runner.unit_local], null, false, true)

	if e.has_execute_failed():
		push_error("Error: %s\npath: %s\nexpr: %s\nunit_local: %s" % [e.get_error_text(), get_path(), text, runner.unit_local])

	return res
