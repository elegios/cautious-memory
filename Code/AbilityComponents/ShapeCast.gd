@tool
## Wait for a [ShapeCast2D] to hit something, save data to the
## blackboard, then finish
class_name ShapeCast extends AbilityTriggered

## A [Vector2] describing where to cast to, relative to the position
## of the [ShapeCast2D]. Defaults to Vector2(0, 0).
@export var relative_target: String
@onready var relative_target_e: Expression = parse_expr(relative_target) if relative_target else null

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"relative_target":
			property.hint = PROPERTY_HINT_EXPRESSION

## Change whether the cast can find the unit itself.
@export var ignore_self: bool = true

## The collision layers to look through.
@export_flags_2d_physics var collision_mask: int = 1

## Optionally change the shape from the default
@export var shape: Shape2D

## Whether to finish after the first collision detected or keep
## going. If true, will run child nodes once per collision, setting
## the blackboard properties below before each. Note that each
## collider is only reported once.
@export var continuous: bool = false

@export_group("Blackboard Output")

## Save the collider(s) to this blackboard property. Not saved if the
## property is empty.
@export var collider: StringName

## Save the point where the collision(s) happened to this blackboard
## property. Not saved if the property is empty.
@export var collision_point: StringName

## Save the collision normal(s) to this blackboard property. Not saved
## if the property is empty.
@export var collision_normal: StringName

func pre_first_process() -> void:
	runner.shape_cast.clear_exceptions()
	# NOTE(vipa, 2024-08-29): This seems like a bug in Godot, since
	# the corresponding method for raycast re-adds the parent if it's
	# to be excluded
	if ignore_self:
		runner.shape_cast.add_exception(runner.shape_cast.get_parent() as CollisionObject2D)

func physics_process_ability(_delta: float) -> ARunResult:
	var sc := runner.shape_cast
	var relative: Vector2 = run_expr(relative_target, relative_target_e) if relative_target_e else Vector2.ZERO
	var new_shape := shape if shape else sc.shape
	var changed := sc.target_position != relative or sc.collision_mask != collision_mask or sc.shape != new_shape or sc.exclude_parent != ignore_self

	if changed:
		sc.exclude_parent = ignore_self
		sc.target_position = relative
		sc.collision_mask = collision_mask
		sc.shape = new_shape
		sc.force_shapecast_update()

	if not sc.is_colliding():
		return ARunResult.Wait

	for i in sc.get_collision_count():
		if collider:
			blackboard.bset(collider, sc.get_collider(i))

		if collision_point:
			blackboard.bset(collision_point, sc.get_collision_point(i))

		if collision_normal:
			blackboard.bset(collision_normal, sc.get_collision_normal(i))

		trigger()

		if not continuous:
			return ARunResult.Done

		sc.add_exception(sc.get_collider(i) as CollisionObject2D)

	return ARunResult.Wait
