class_name MobMovement extends Node

## Only units within vision range (i.e., those detected by this
## [Area2D]) will affect movement.
@export var vision: Area2D

## The ability runner of this mob. No movement will be done while a
## main ability is running.
@export var runner: AbilityRunner

## If the resulting directional vector is shorter than this threshold,
## ignore it and move no movement.
@export var movement_threshold: float = 0.05

@export_group("Target")

## The system for managing aggro. Will not move towards a target if
## absent.
@export var aggro: Aggro

## Optional. Use this nav_agent to get to the target when outside
## [member MobMovement.target_max_distance]. Will move straight
## towards the target if absent.
@export var nav_agent: NavigationAgent2D

## The desired minimum distance to target. Will walk away if the
## distance between the two unit centers is lower than this.
@export var target_min_distance: float = 32

## The desired maximum distance to target. Will walk towards the
## target if the distance between the two unit centers is higher than
## this.
@export var target_max_distance: float = 80

## The weight of the movement vector from this component while we're
## outside the min-max range to the target.
@export var target_outside_strength: float = 1.0

## The weight of the movement vector from this component while we're
## outside the min-max range to the target. Will try to move towards
## the center of the min-max range.
@export var target_inside_strength: float = 0.1

@export_group("Mob Avoidance")

@export_flags_2d_physics var enemy_layer: int = 1 << 5

## Other enemies beyond this range will not impact the avoidance of
## this unit.
@export var mob_avoidance_max_range: float = 40

## How strongly to prioritize avoiding another enemy depending on
## distance. The x-axis is unit distance relative to [member
## MobMovement.mob_avoidance_max_range]; [code]1.0 [/code] is
## maximally far away, [code]0.0[/code] is at the exact same
## co-ordinates.
@export var mob_avoidance_strength: Curve

# @export_group("Terrain Avoidance")

# ## Other enemies beyond this range will not impact the avoidance of
# ## this unit.
# @export var terrain_avoidance_max_range: float = 40

# ## How strongly to prioritize avoiding another enemy depending on
# ## distance. The x-axis is unit distance relative to [member
# ## MobMovement.avoidance_max_range]; [code]1.0 [/code] is maximally
# ## far away, [code]0.0[/code] is at the exact same co-ordinates.
# @export var terrain_avoidance_strength: Curve

@onready var parent: Node2D = get_parent()

func get_movement_direction() -> Vector2:
	var res := Vector2.ZERO

	if runner and runner.is_main_ability_running():
		return Vector2.ZERO

	var target := aggro.get_target_or_null() if aggro else null
	if target:
		var dir := parent.position - target.position
		if dir.length_squared() > target_max_distance * target_max_distance:
			if nav_agent:
				nav_agent.target_position = target.position
				res += parent.position.direction_to(nav_agent.get_next_path_position()) * target_outside_strength
			else:
				res -= dir.normalized() * target_outside_strength
		elif dir.length_squared() < target_min_distance * target_min_distance:
			res += dir.normalized() * target_outside_strength
		elif not is_zero_approx(target_inside_strength):
			res += (target.position + dir.normalized() * (target_min_distance + target_max_distance) / 2).direction_to(parent.position) * target_inside_strength

	for n in vision.get_overlapping_bodies():
		var u := n as CollisionObject2D

		# Other enemy, run mob_avoidance stuff
		if u.collision_layer & enemy_layer and not u.position.direction_to(parent.position).is_zero_approx() and u.position.distance_squared_to(parent.position) <= mob_avoidance_max_range * mob_avoidance_max_range:
			var dist := u.position.distance_to(parent.position)
			var scale := mob_avoidance_strength.sample(dist / mob_avoidance_max_range)
			res += (parent.position - u.position) / dist * scale

	if res.length_squared() < movement_threshold * movement_threshold:
		return Vector2.ZERO

	return res
