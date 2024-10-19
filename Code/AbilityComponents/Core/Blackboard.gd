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

enum Err {
	None = 0,
	MissingNormal = 1,
	MissingUnit = 2,
	MissingM = 4,
}

var errs : int = Err.None

func _get(property: StringName) -> Variant:
	# NOTE(vipa, 2024-10-11): Should be kept in sync with `bget`, except return false and populate `errs`
	match _is_special.get(property, Kind.Normal):
		Kind.Normal:
			if not _dict.has(property):
				if property.begins_with("m_"):
					errs |= Err.MissingM
				else:
					errs |= Err.MissingNormal
				return false
			var res: Variant = _dict.get(property, false)
			return res if res != null else false
		Kind.Unit:
			var ret : Node2D = spawner.id_to_unit.get(_dict[property], null)
			if not ret:
				errs |= Err.MissingUnit
				return false
			return ret
	return false

func bget(property: StringName, allow_empty: bool = false) -> Variant:
	# NOTE(vipa, 2024-10-11): Should be kept in sync with `_get`
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

func bset_unit(property: StringName, value: Node) -> void:
	if property.begins_with("m_"):
		_updated_m[property] = true

	_is_special[property] = Kind.Unit
	_dict[property] = spawner.unit_to_id[value] if value else -1

func bclear(property: StringName) -> void:
	if property.begins_with("m_"):
		_updated_m[property] = true

	var _ignore := _dict.erase(property)
	_ignore = _is_special.erase(property)

func _to_string() -> String:
	return str(_dict)
