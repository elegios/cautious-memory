class_name AnimatedUnit extends AnimatedSprite2D

enum Dir { None, SE, SW, NE, NW }
enum A {
	None,
	Idle,
	Walk,
	Attack,
	Jump,
}

var unit_direction: Dir = Dir.SE:
	set(value):
		unit_direction = value
		_update_animation_later()
var unit_animation: A = A.Idle:
	set(value):
		unit_animation = value
		_update_animation_later()
var unit_animation_duration: float = -1.0:
	set(value):
		unit_animation_duration = value
		_update_animation_later()

var overlaid_direction: Dir:
	set(value):
		overlaid_direction = value
		_update_animation_later()
var overlaid_animation: A:
	set(value):
		overlaid_animation = value
		_update_animation_later()
var overlaid_animation_duration: float = -1.0:
	set(value):
		overlaid_animation_duration = value
		_update_animation_later()

var overlaid_owner: Node = null

var anim_update_deferred := false

func _ready() -> void:
	var _ignore := animation_finished.connect(_remove_overlay)

func set_overlay(anim: A, dir: Dir = Dir.None, duration: float = -1.0, overlay_owner: Node = null) -> void:
	if anim != A.None and not overlaid_owner:
		overlaid_animation = anim
		overlaid_direction = dir
		overlaid_animation_duration = duration
		overlaid_owner = overlay_owner
	elif anim == A.None and overlaid_owner == overlay_owner:
		overlaid_animation = A.None
		overlaid_direction = Dir.None
		overlaid_animation_duration = 0.0
		overlaid_owner = null

func _update_animation_later() -> void:
	if anim_update_deferred:
		return
	_update_animation.call_deferred()
	anim_update_deferred = true

func _update_animation() -> void:
	anim_update_deferred = false
	var expected_dir := unit_direction
	var expected_anim := unit_animation
	var expected_dur := unit_animation_duration
	if overlaid_animation != A.None:
		expected_dir = overlaid_direction if overlaid_direction != Dir.None else expected_dir
		expected_anim = overlaid_animation
		expected_dur = overlaid_animation_duration

	var anim: StringName = ""
	while expected_dir != Dir.None:
		anim = anim_str(expected_anim, expected_dir)
		if sprite_frames.has_animation(anim):
			break
		expected_dir = next_default_dir(expected_dir)
	if expected_dir <= 0:
		push_error("This animation does not exist: " + str(expected_anim))
		return

	var actual_duration := sprite_frames.get_frame_count(anim) / sprite_frames.get_animation_speed(anim)
	if animation != anim or (expected_dur > 0 and get_playing_speed() != actual_duration / expected_dur):
		play(anim, actual_duration / expected_dur if expected_dur > 0 else 1.0)

func a_to_string(a: A) -> String:
	match a:
		A.None, A.Idle:
			return "idle"
		A.Walk:
			return "walk"
		A.Attack:
			return "attack"
		A.Jump:
			return "jump"
	push_error("Missed animation: " + str(a) + str(A))
	return "idle"

func dir_to_string(d: Dir) -> String:
	match d:
		Dir.SE:
			return "se"
		Dir.SW:
			return "sw"
		Dir.NE:
			return "ne"
		Dir.NW:
			return "nw"
	return ""

func anim_str(a: A, dir: Dir) -> StringName:
	return "%s-%s" % [a_to_string(a), dir_to_string(dir)]

func next_default_dir(dir: Dir) -> Dir:
	match dir:
		Dir.SE:
			return Dir.None
		Dir.NE:
			return Dir.SE
		Dir.NW:
			return Dir.SW
		Dir.SW:
			return Dir.SE
	return Dir.None

func _remove_overlay() -> void:
	overlaid_animation = A.None
	overlaid_animation_duration = 0
	overlaid_direction = Dir.None
	overlaid_owner = null