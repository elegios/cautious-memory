@icon("res://Code/AbilityComponents/Icons/ShapeCast.svg")
@tool
## Wait for a [ShapeCast2D] to hit something, save data to the
## blackboard, then finish
class_name ShapeCast extends AbilityTriggered

## A [Vector2] describing the point at which to put the shape
## cast. Defaults to [code]character.position[/code].
@export var cast_position: String
@onready var cast_position_e: Expression = parse_expr(cast_position) if cast_position else null

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"cast_position", "additional_ignore":
			property.hint = PROPERTY_HINT_EXPRESSION

## Change whether the cast can find the unit itself.
@export var ignore_self: bool = true

## Optional. Ignore this unit as well.
@export var additional_ignore: String
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

func pre_first_process() -> void:
	runner.shape_cast.clear_exceptions()
	# NOTE(vipa, 2024-08-29): This seems like a bug in Godot, since
	# the corresponding method for raycast re-adds the parent if it's
	# to be excluded
	if ignore_self:
		runner.shape_cast.add_exception(runner.shape_cast.get_parent() as CollisionObject2D)
	if additional_ignore_e:
		var extra : CollisionObject2D = run_expr(additional_ignore, additional_ignore_e)
		runner.shape_cast.add_exception(extra)

func physics_process_ability(_delta: float) -> ARunResult:
	var sc := runner.shape_cast
	var cast_pos: Vector2 = run_expr(cast_position, cast_position_e) if cast_position_e else runner.character.global_position

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

			trigger()

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

		trigger()

		return ARunResult.Done

	return ARunResult.Wait
