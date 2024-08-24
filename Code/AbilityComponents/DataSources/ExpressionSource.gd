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

func setup(r: AbilityRunner, b: Dictionary) -> void:
	super(r, b)
	if x:
		x.setup(r, b)
	if y:
		y.setup(r, b)
	if z:
		z.setup(r, b)

func register_properties(node: Node, property: String, root: AbilityRoot) -> void:
	super(node, property, root)
	if x:
		x.register_properties(node, property + ":x", root)
	if y:
		y.register_properties(node, property + ":y", root)
	if z:
		z.register_properties(node, property + ":z", root)

func get_data(delta: float) -> Variant:
	var xval: Variant = x.get_data(delta) if x else null
	var yval: Variant = y.get_data(delta) if y else null
	var zval: Variant = z.get_data(delta) if z else null
	var res: Variant = parsed.execute([xval, yval, zval])
	if parsed.has_execute_failed():
		push_error("Error: %s\nx: %s\ny: %s\nz %s\ndebug_server: %s" % [parsed.get_error_text(), xval, yval, zval, OS.has_feature("debug_server")])
	return res
