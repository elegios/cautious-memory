class_name CurveSource extends DataSource

@export var duration: float = 1.0
@export var curve: Curve

var elapsed: float = 0.0

func register_properties(node: Node, property: String, root: AbilityRoot) -> void:
	root.register_prop(node, property + ":elapsed")

func get_data(delta: float) -> Variant:
	elapsed += delta
	return curve.sample(elapsed / duration)
