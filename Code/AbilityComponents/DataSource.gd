## Base class of data sources used to parameterize ability
## actions. Should not be used directly, only through subclasses.
class_name DataSource extends Resource

func get_data(_player: Player, _blackboard: Dictionary) -> Variant:
	return null
