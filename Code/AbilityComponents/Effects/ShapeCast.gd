@icon("res://Code/AbilityComponents/Icons/ShapeCast.svg")
## Wait for a [ShapeCast2D] to hit something, save data to the
## blackboard, then finish
class_name ShapeCast extends AbilityTriggered

## A [Vector2] describing the point at which to put the shape
## cast. Defaults to [code]character.position[/code].
@export_custom(PROPERTY_HINT_EXPRESSION, "") var cast_position: String
@onready var cast_position_e: Expression = parse_expr(cast_position) if cast_position else null

## Change whether the cast can find the unit itself.
@export var ignore_self: bool = true

## Optional. Ignore this unit as well.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var additional_ignore: String
@onready var additional_ignore_e := parse_expr(additional_ignore) if additional_ignore else null

## The collision layers to look through.
@export_flags_2d_physics var collision_mask: int = 1

## The shape to cast with. Mandatory.
@export var shape: Shape2D

## Whether to finish after the first collision detected or keep
## going. If true, will run child nodes once per collision, setting
## the blackboard properties below before each. Note that each
## collider is only reported once.
@export var continuous: bool = false

enum PMode { Arbitrary, Center }

## Which target to prioritize when [i]not[/i] continuous.
@export var prioritization_mode := PMode.Arbitrary

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

func load_state(_buffer: Array, idx: int, was_active: bool) -> int:
	if not was_active:
		var _ignore := activate()
	return idx

func activate() -> ARunResult:
	runner.shape_cast.clear_exceptions()
	# NOTE(vipa, 2024-08-29): This seems like a bug in Godot, since
	# the corresponding method for raycast re-adds the parent if it's
	# to be excluded
	if ignore_self:
		runner.shape_cast.add_exception(runner.shape_cast.get_parent() as CollisionObject2D)
	if additional_ignore_e:
		var res := run_expr(additional_ignore, additional_ignore_e)
		if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not CollisionObject2D):
			return ARunResult.Error
		var extra : CollisionObject2D = res.value
		runner.shape_cast.add_exception(extra)

	return ARunResult.Wait

func physics_process_ability(_delta: float, first: bool) -> ARunResult:
	if first:
		var act_res := activate()
		if act_res != ARunResult.Wait:
			return act_res

	var sc := runner.shape_cast
	var res := run_expr(cast_position, cast_position_e) if cast_position_e else ExprRes.new(runner.character.global_position)
	if res.err == Err.ShouldBail or (res.err == Err.MightBail and res.value is not Vector2):
		return ARunResult.Error
	var cast_pos: Vector2 = res.value

	sc.exclude_parent = ignore_self
	sc.global_position = cast_pos
	sc.collision_mask = collision_mask
	sc.shape = shape
	sc.force_shapecast_update()

	if not sc.is_colliding():
		return ARunResult.Wait

	if continuous:
		for i in sc.get_collision_count():
			if collider:
				blackboard.bset(collider, sc.get_collider(i))

			if collision_point:
				blackboard.bset(collision_point, sc.get_collision_point(i))

			if collision_normal:
				blackboard.bset(collision_normal, sc.get_collision_normal(i))

			if trigger() == ARunResult.Error:
				return ARunResult.Error

			sc.add_exception(sc.get_collider(i) as CollisionObject2D)
	else:
		var collider_idx := 0
		match prioritization_mode:
			PMode.Arbitrary:
				pass
			PMode.Center:
				var pos := sc.global_position + sc.target_position
				var prev := (sc.get_collider(collider_idx) as Node2D).position.distance_squared_to(pos)
				for i in sc.get_collision_count():
					var next := (sc.get_collider(i) as Node2D).position.distance_squared_to(pos)
					if next < prev:
						prev = next
						collider_idx = i
		if collider:
			blackboard.bset(collider, sc.get_collider(collider_idx))

		if collision_point:
			blackboard.bset(collision_point, sc.get_collision_point(collider_idx))

		if collision_normal:
			blackboard.bset(collision_normal, sc.get_collision_normal(collider_idx))

		if trigger() == ARunResult.Error:
			return ARunResult.Error

		return ARunResult.Done

	return ARunResult.Wait
