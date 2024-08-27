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

func maybe_duplicate() -> DataSource:
	var new_x := x.maybe_duplicate() if x else null
	var new_y := y.maybe_duplicate() if y else null
	var new_z := z.maybe_duplicate() if z else null

	if x != new_x or y != new_y or z != new_z:
		var ret: ExpressionSource = duplicate()
		ret.x = new_x
		ret.y = new_y
		ret.z = new_z
		return ret
	return self

func _validate_property(property: Dictionary) -> void:
	if property.name == "expression":
		property.hint = PROPERTY_HINT_EXPRESSION

func setup(r: AbilityRunner, b: Dictionary) -> DataSource:
	var ret: ExpressionSource = super(r, b)
	if ret.x:
		ret.x = x.setup(r, b)
	if ret.y:
		ret.y = y.setup(r, b)
	if ret.z:
		ret.z = z.setup(r, b)
	return ret

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
