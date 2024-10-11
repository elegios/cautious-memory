@icon("../Icons/PlayAnimation.svg")
@tool
## Play an animation on an [AnimatedUnit].
class_name PlayAnimation extends AbilityNode


## The animation to play.
@export var animation: AnimatedUnit.A = AnimatedUnit.A.None

## The direction to face. Either a direction vector, or an angle. The
## closest available animation angle will be selected. If absent, or
## null, do not change the facing direction.
@export var direction: String
@onready var direction_e := parse_expr(direction) if direction else null

## The duration of the animation. The animation will be scaled to be
## this long (float, seconds) if present. A negative number means "use
## original duration". If the animation is looping, one iteration will
## be this long.
@export var duration: String
@onready var duration_e := parse_expr(duration) if duration else null

## If true, set the animation to run once independently of this node,
## which makes this node finish immediately. If false, the animation
## playing is tied to this node executing, i.e., interrupting the node
## interrupts the animation, and when the animation ends this node
## completes execution.
@export var fire_and_forget := false

var animation_finished := false
var animation_started := false

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"direction", "duration":
			property.hint = PROPERTY_HINT_EXPRESSION

func pre_first_process() -> void:
	animation_finished = false
	animation_started = false

	if not fire_and_forget:
		var _ignore := runner.animator.animation_finished.connect(_animation_over)

func sync_gained() -> void:
	pre_first_process()

func sync_lost() -> void:
	if not fire_and_forget:
		runner.animator.animation_finished.disconnect(_animation_over)
		runner.animator.set_overlay(AnimatedUnit.A.None, AnimatedUnit.Dir.SE, 0.0, self)

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	var res := super(kind)
	if res == AInterruptResult.Interrupted:
		sync_lost()
	return res

func physics_process_ability(_delta: float) -> ARunResult:
	if not animation_started:
		animation_started = true
		# NOTE(vipa, 2024-10-01): Pick a direction
		var dir := AnimatedUnit.Dir.None
		var dir_res := run_expr(direction, direction_e) if direction_e else ExprRes.new(null)
		if dir_res.err == Err.ShouldBail or (dir_res.err == Err.MightBail and dir_res.value is not Vector2 and dir_res.value is not float):
			sync_lost()
			return ARunResult.Error
		if dir_res.value is Vector2:
			var dir_vec: Vector2 = dir_res.value
			if dir_vec.x >= 0 and dir_vec.y >= 0:
				dir = AnimatedUnit.Dir.SE
			elif dir_vec.x >= 0 and dir_vec.y < 0:
				dir = AnimatedUnit.Dir.NE
			elif dir_vec.x < 0 and dir_vec.y >= 0:
				dir = AnimatedUnit.Dir.SW
			elif dir_vec.x < 0 and dir_vec.y < 0:
				dir = AnimatedUnit.Dir.NW
		elif dir_res.value is float:
			var dir_ang: float = dir_res.value
			if 0 < dir_ang and dir_ang <= PI/2:
				dir = AnimatedUnit.Dir.SE
			elif PI/2 < dir_ang and dir_ang < PI:
				dir = AnimatedUnit.Dir.NE
			elif PI <= dir_ang and dir_ang < 3*PI/4:
				dir = AnimatedUnit.Dir.NE
			elif 3*PI/4 <= dir_ang and (dir_ang == 0 or dir_ang <= 2*PI):
				dir = AnimatedUnit.Dir.SE
		elif dir_res.value == null :
			pass
		else:
			assert(false, mk_expr_error(direction, "result (%s) is neither Vector2 nor float" % dir_res.value))

		var dur := run_expr(duration, duration_e) if duration_e else ExprRes.new(-1.0)
		if dur.err == Err.ShouldBail or (dur.err == Err.MightBail and dur.value is not float):
			sync_lost()
			return ARunResult.Error
		var dur_f : float = dur.value
		runner.animator.set_overlay(animation, dir, dur_f, null if fire_and_forget else self)

	if fire_and_forget or animation_finished:
		sync_lost()
		return ARunResult.Done
	return ARunResult.Wait

func _animation_over() -> void:
	animation_finished = true
