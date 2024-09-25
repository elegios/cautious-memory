@tool
## Create a [i]non-gameplay[/i] related effect at a position or locked
## onto a unit.
class_name CreateEffect extends AbilityNode


## The scene to instantiate as an effect. Should remove itself, it
## will not get removed automatically by anything else.
@export var effect: PackedScene

## Where to create the effect. Can be a position (Vector2) or a
## unit. If it is a unit, the effect will follow the position of that
## unit. Defaults to the current character if absent.
@export var target: String
@onready var target_e := parse_expr(target) if target else null

enum What { Direction, Position }

## How to interpret the rotation field if it is a Vector2 or unit. If
## Direction, will treat the vector as a direction to face and take
## the rotation of the unit. If Position, will face the point
## represented by the vector or the current position of the unit,
## respectively.
@export var what: What = What.Direction

## The rotation to use. Can be an angle (float, in radians), a
## Vector2, or a unit. A vector is snapshotted and applied
## immediately, while a unit will be tracked for the lifetime of the
## effect. Defaults to 0 if unset.
@export var rotation: String
@onready var rotation_e := parse_expr(rotation) if rotation else null

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"target", "rotation":
			property.hint = PROPERTY_HINT_EXPRESSION

func physics_process_ability(_delta: float) -> ARunResult:
	var fx: Node2D = effect.instantiate()
	runner.unit_spawner.get_parent().add_child(fx)

	var target_value: Variant = run_expr(target, target_e) if target_e else runner.character
	var direction_value: Variant = run_expr(rotation, rotation_e) if rotation_e else 0

	if target_value is Vector2:
		var pos: Vector2 = target_value
		fx.position = pos
	elif target_value is Node2D:
		var u: Node2D = target_value
		var r := RemoteTransform2D.new()
		r.update_position = true
		r.update_rotation = false
		r.update_scale = false
		u.add_child(r)
		r.remote_path = r.get_path_to(fx)
		var _i := fx.tree_exiting.connect(r.queue_free)

	if direction_value is float:
		var r: float = direction_value
		fx.rotation = r
	elif direction_value is Vector2:
		var dir: Vector2 = direction_value
		if what == What.Direction:
			fx.rotation = dir.angle()
		elif what == What.Position:
			fx.rotation = fx.position.angle_to_point(dir)
	elif direction_value is Node2D:
		var u: Node2D = direction_value
		if what == What.Direction:
			var r := RemoteTransform2D.new()
			r.update_position = false
			r.update_rotation = true
			r.update_scale = false
			u.add_child(r)
			r.remote_path = r.get_path_to(fx)
			var _i := fx.tree_exiting.connect(r.queue_free)
		elif what == What.Position:
			push_error("Not yet implemented")

	return ARunResult.Done
