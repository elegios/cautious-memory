## Read data from the ability-local blackboard.
class_name BlackboardSource extends DataSource

## The property to read from the blackboard.
@export var property: StringName
## Whether to allow absent properties. If true, an absent property
## will act as though 'null' was written to it.
@export var allow_absent: bool = false

func get_data(_delta: float) -> Variant:
	if not allow_absent and not blackboard.has(property):
		push_error("Missing blackboard key: " + property)
	var ret: Variant = blackboard.get(property, null)
	if ret is NodePath:
		var path: NodePath = ret
		var node := runner.get_node_or_null(path)
		return node
	elif ret is Array[NodePath]:
		var paths: Array[NodePath] = ret
		var res: Array[Node] = []
		for p in paths:
			var node := runner.get_node(p)
			if not node:
				push_error("Bad nodepath: " + str(p))
			res.append(node)
		return res
	return ret
