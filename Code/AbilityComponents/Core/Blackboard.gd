class_name Blackboard extends RefCounted

var _dict: Dictionary = {}
var _is_special: Dictionary = {}
var _updated_m: Dictionary = {}

enum Kind {
	Normal,
	Unit,
}

var spawner: UnitSpawner

func _init(s: UnitSpawner) -> void:
	spawner = s

func bget(property: StringName, allow_empty: bool = false) -> Variant:
	match _is_special.get(property, Kind.Normal):
		Kind.Normal:
			if not allow_empty and not _dict.has(property):
				push_error("Missing property in blackboard: " + property)

			return _dict.get(property, null)
		Kind.Unit:
			return spawner.id_to_unit.get(_dict[property], null)
	return null


func bset(property: StringName, value: Variant) -> void:
	if property.begins_with("m_"):
		_updated_m[property] = true

	if value is Node:
		var n: Node = value
		_dict[property] = spawner.unit_to_id[n]
		_is_special[property] = Kind.Unit
		return

	_dict[property] = value
	var _ignore := _is_special.erase(property)

func bclear(property: StringName) -> void:
	if property.begins_with("m_"):
		_updated_m[property] = true

	var _ignore := _dict.erase(property)
	_ignore = _is_special.erase(property)

func save_state(buffer: Array) -> void:
	buffer.push_back(_dict)
	buffer.push_back(_is_special)

func load_state(buffer: Array, idx: int) -> int:
	_dict = buffer[idx]
	_is_special = buffer[idx+1]
	return idx + 2

func duplicate_no_m() -> Blackboard:
	var ret := Blackboard.new(spawner)
	for k: StringName in _dict:
		if k.begins_with("m_"):
			continue
		ret._dict[k] = _dict[k]
		if _is_special.has(k):
			ret._is_special[k] = _is_special[k]
	return ret

## Copy properties from [param other] to self.
func merge(other: Blackboard) -> void:
	for k: StringName in other._dict:
		_dict[k] = other._dict[k]
		if other._is_special.has(k):
			_is_special[k] = other._is_special[k]
		else:
			var _ignore := _is_special.erase(k)

## Copy [code]m_[/code] properties from [param other] to self.
func merge_m(other: Blackboard) -> void:
	for k: StringName in other._updated_m:
		if other._dict.has(k):
			_dict[k] = other._dict[k]
			if other._is_special.has(k):
				_is_special[k] = other._is_special[k]
			else:
				var _ignore := _is_special.erase(k)
		else:
			var _ignore := _dict.erase(k)
			_ignore = _is_special.erase(k)

func _get(property: StringName) -> Variant:
	var res: Variant = bget(property, true)
	# NOTE(vipa, 2024-09-12): The _get function should return null if
	# the property should be handled by the normal system, which is an
	# issue here, because we actually want to be able to return
	# null. We work around it by returning false instead, since most
	# such uses just check for truthyness.
	if res == null:
		return false
	return res

func _to_string() -> String:
	return str(_dict)
