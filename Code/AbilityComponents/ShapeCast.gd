## Wait for a [ShapeCast2D] to hit something, save data to the
## blackboard, then finish
class_name ShapeCast extends AbilityNode

## A [Vector2] describing where to cast to, relative to the position
## of the [ShapeCast2D]. Defaults to Vector2(0, 0).
@export var relative_target: DataSource

## Change whether the cast can find the unit itself.
@export var ignore_self: bool = true

## The collision layers to look through.
@export_flags_2d_physics var collision_mask: int = 1

## Optionally change the shape from the default
@export var shape: Shape2D

@export_group("Blackboard Output")

## Save data from [i]all[/i] cast hits. If true, save arrays for all
## properties below, otherwise just a single value.
@export var save_all: bool = false

## Save the collider(s) to this blackboard property. Not saved if the
## property is empty.
@export var collider: StringName

## Save the position(s) of the collider(s) to this blackboard
## property. Not saved if the property is empty.
@export var collider_position: StringName

## Save the point where the collision(s) happened to this blackboard
## property. Not saved if the property is empty.
@export var collision_point: StringName

## Save the collision normal(s) to this blackboard property. Not saved
## if the property is empty.
@export var collision_normal: StringName

func setup(a: AbilityRunner, b: Dictionary) -> void:
	if relative_target:
		relative_target = relative_target.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	if relative_target:
		relative_target.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	if relative_target:
		idx = relative_target.load_state(buffer, idx)
	return idx

func pre_first_process() -> void:
	if relative_target:
		relative_target.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	var sc := runner.shape_cast
	var relative: Vector2 = relative_target.get_data(delta) if relative_target else Vector2.ZERO
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

	if collider:
		if save_all:
			var res := []
			for i in sc.get_collision_count():
				res.append((sc.get_collider(i) as Node2D).get_path())
			blackboard[collider] = res
		else:
			blackboard[collider] = (sc.get_collider(0) as Node2D).get_path()

	if collider_position:
		if save_all:
			var res := []
			for i in sc.get_collision_count():
				res.append((sc.get_collider(i) as Node2D).position)
			blackboard[collider_position] = res
		else:
			blackboard[collider_position] = (sc.get_collider(0) as Node2D).position

	if collision_point:
		if save_all:
			var res := []
			for i in sc.get_collision_count():
				res.append(sc.get_collision_point(i))
			blackboard[collision_point] = res
		else:
			blackboard[collision_point] = sc.get_collision_point(0)

	if collision_normal:
		if save_all:
			var res := []
			for i in sc.get_collision_count():
				res.append(sc.get_collision_normal(i))
			blackboard[collision_normal] = res
		else:
			blackboard[collision_normal] = sc.get_collision_normal(0)

	return ARunResult.Done
