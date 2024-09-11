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

func setup(r: AbilityRunner, b: Blackboard) -> DataSource:
	var ret: ExpressionSource = super(r, b)
	if ret.x:
		ret.x = x.setup(r, b)
	if ret.y:
		ret.y = y.setup(r, b)
	if ret.z:
		ret.z = z.setup(r, b)
	return ret

func save_state(buffer: Array) -> void:
	if x:
		x.save_state(buffer)
	if y:
		y.save_state(buffer)
	if z:
		z.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	if x:
		idx = x.load_state(buffer, idx)
	if y:
		idx = y.load_state(buffer, idx)
	if z:
		idx = z.load_state(buffer, idx)
	return idx

func pre_first_data() -> void:
	if x:
		x.pre_first_data()
	if y:
		y.pre_first_data()
	if z:
		z.pre_first_data()

func get_data(delta: float) -> Variant:
	var xval: Variant = x.get_data(delta) if x else null
	var yval: Variant = y.get_data(delta) if y else null
	var zval: Variant = z.get_data(delta) if z else null
	var res: Variant = parsed.execute([xval, yval, zval], null, false)
	if parsed.has_execute_failed():
		push_error("Error(%s): %s\nexpr: %s\nx: %s\ny: %s\nz %s\ndebug_server: %s" % [runner.get_path(), parsed.get_error_text(), expression, xval, yval, zval, OS.has_feature("debug_server")])
	return res
