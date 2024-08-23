## Compute a new value, potentially based on intermediate values
## obtained from other data sources.
@tool
class_name ExpressionSource extends DataSource

## The expression run to compute the final value. Note that 'x', 'y',
## and 'z' are available and bound to values obtained from the data
## sources below, or 'null' if absent.
@export var expression: String:
	set(value):
		expression = value
		var res := parsed.parse(expression, ["x", "y", "z"])
		if OK != res:
			print(error_string(res))
			push_error(parsed.get_error_text())
	get:
		return expression
var parsed: Expression = Expression.new()

## Optionally obtain values to compute with from another data source,
## exposing it to the expression through the 'x' variable
@export var x: DataSource
## Optionally obtain values to compute with from another data source,
## exposing it to the expression through the 'y' variable
@export var y: DataSource
## Optionally obtain values to compute with from another data source,
## exposing it to the expression through the 'z' variable
@export var z: DataSource

func _validate_property(property: Dictionary) -> void:
	if property.name == "expression":
		property.hint = PROPERTY_HINT_EXPRESSION

func get_data(p: Player, b: Dictionary) -> Variant:
	var res: Variant = parsed.execute([x.get_data(p, b) if x else null, y.get_data(p, b) if y else null, z.get_data(p, b) if z else null])
	if parsed.has_execute_failed():
		push_error(parsed.get_error_text())
	return res
