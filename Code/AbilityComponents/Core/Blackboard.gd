class_name Blackboard extends RefCounted

var dict: Dictionary = {}
var is_special: Dictionary = {}

enum Kind {
	Normal,
	Unit,
}

var spawner: UnitSpawner

func _init(s: UnitSpawner) -> void:
	spawner = s

func bget(property: StringName, allow_empty: bool = false) -> Variant:
	match is_special.get(property, Kind.Normal):
		Kind.Normal:
			if not allow_empty and not dict.has(property):
				push_error("Missing property in blackboard: " + property)

			return dict.get(property, null)
		Kind.Unit:
			return spawner.id_to_unit.get(dict[property], null)
	return null


func bset(property: StringName, value: Variant) -> void:
	if value is Node:
		var n: Node = value
		dict[property] = spawner.unit_to_id[n]
		is_special[property] = Kind.Unit
		return

	dict[property] = value
	var _ignore := is_special.erase(property)

func bclear(property: StringName) -> void:
	var _ignore := dict.erase(property)
	_ignore = is_special.erase(property)

func save_state(buffer: Array) -> void:
	buffer.push_back(dict)
	buffer.push_back(is_special)

func load_state(buffer: Array, idx: int) -> int:
	dict = buffer[idx]
	is_special = buffer[idx+1]
	return idx + 2

func duplicate_no_m() -> Blackboard:
	var ret := Blackboard.new(spawner)
	for k: StringName in dict:
		if k.begins_with("m_"):
			continue
		ret.dict[k] = dict[k]
		if is_special.has(k):
			ret.is_special[k] = is_special[k]
	return ret

## Copy properties from [param other] to self.
func merge(other: Blackboard) -> void:
	for k: StringName in other.dict:
		dict[k] = other.dict[k]
		if other.is_special.has(k):
			is_special[k] = other.is_special[k]
		else:
			var _ignore := is_special.erase(k)

## Copy [code]m_[/code] properties from [param other] to self.
func merge_m(other: Blackboard) -> void:
	for k: StringName in other.dict:
		if not k.begins_with("m_"):
			continue

		dict[k] = other.dict[k]
		if other.is_special.has(k):
			is_special[k] = other.is_special[k]
		else:
			var _ignore := is_special.erase(k)
