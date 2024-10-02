extends Health

@export var max_health := 6

@export_group("Chip Damage")

## Damage below this size is considered chip damage, which can
## compound to be real damage, but might just as easily be reset
## relatively quickly.
@export var chip_size := 10.0

## Time from last health alteration at which to reset chip-damage in
## seconds. Should be less than the *_start_time values for
## regeneration and the like.
@export var chip_reset_time := 6.0

@export_group("Regenerating Health")

## Time from last health alteration at which to start regenerating
## health (i.e., gaining health after having taken damage).
@export var regen_start_time := 20.0

## Time between each tick once regeneration has started.
@export var regen_interval := 2.0

## Time from last health alteration at which to start losing
## overhealth.
@export var degen_start_time := 10.0

## Time between each tick once degeneration has started
@export var degen_interval := 0.5

## Current health as a diff from 0. Death occurs when
## current_health_diff <= -max_health. A positive diff is overhealing,
## which caps at max_health.
var current_health_diff := 0:
	set(value):
		update_visualization(current_health_diff, value)
		current_health_diff = value

## Current chip damage as a diff from 0. Damage is negative, healing
## is positive. Turns into real damage/healing at -/+ chip_size.
var current_chip_diff := 0.0:
	set(value):
		current_chip_diff = value
		update_visualization(current_health_diff, current_health_diff)

@onready var regen_timer: Timer = %"RegenTimer"
@onready var chip_timer: Timer = %"ChipTimer"
@onready var hp_container: HBoxContainer = %"HPContainer"
@onready var chip_particles: GPUParticles2D = %"ChipParticles"

func _ready() -> void:
	for _i in max_health - 1:
		hp_container.add_child(hp_container.get_child(0).duplicate())

func _alter_health(delta: float) -> float:
	var prev_h := current_health_diff
	var prev_c := current_chip_diff

	var hdiff := int(delta/chip_size)  # NOTE(vipa, 2024-09-24): This rounds towards zero
	var cdiff := delta - hdiff*chip_size

	# NOTE(vipa, 2024-09-24): There are *many* variations of how
	# health could work, this is one particular set of choices that
	# hopefully makes player health feel like an integral number, with
	# the addition of chip-damage.

	if hdiff != 0:
		# NOTE(vipa, 2024-09-24): We ignore chip damage entirely if we
		# have non-chip damage
		current_health_diff = clampi(current_health_diff+hdiff, -max_health, +max_health)
		current_chip_diff = 0.0
	elif not is_zero_approx(cdiff):
		# NOTE(vipa, 2024-09-24): We truncate chip damage when it exceeds
		# chip_size, i.e., we might lose a little bit of damage/healing
		# when this happens.
		current_chip_diff += cdiff
		if current_chip_diff <= -chip_size:
			current_health_diff = maxi(current_health_diff-1, -max_health)
			current_chip_diff = 0.0
		elif current_chip_diff >= chip_size:
			current_health_diff = mini(current_health_diff+1, max_health)
			current_chip_diff = 0.0
	else:
		return 0.0

	regen_timer.stop()
	chip_timer.stop()
	if current_health_diff != 0:
		regen_timer.one_shot = true
		regen_timer.start(regen_start_time if current_health_diff < 0 else degen_start_time)
	if not is_zero_approx(current_chip_diff):
		chip_timer.start(chip_reset_time)

	return (current_health_diff - prev_h)*chip_size + (current_chip_diff - prev_c)

func _on_regen_timer_timeout() -> void:
	if regen_timer.one_shot:
		# NOTE(vipa, 2024-09-24): Start regen/degen
		regen_timer.one_shot = false
		if de_re():
			regen_timer.start(regen_interval if current_health_diff < 0 else degen_interval)
	else:
		# NOTE(vipa, 2024-09-24): Tick during regen/degen
		if not de_re():
			regen_timer.stop()

func de_re() -> bool:
	current_chip_diff = 0.0
	if current_health_diff < 0:
		current_health_diff += 1
	elif current_health_diff > 0:
		current_health_diff -= 1
	return current_health_diff != 0

func _on_chip_timer_timeout() -> void:
	current_chip_diff = 0.0

func update_visualization(prev_hdiff: int, new_hdiff: int) -> void:
	if not hp_container:
		return

	var first := max_health + mini(prev_hdiff, new_hdiff)
	var last := max_health + maxi(prev_hdiff, new_hdiff)
	var increase := new_hdiff > prev_hdiff
	var target_rel_pos := Vector2.ZERO if increase else Vector2(0, 10)
	var target_alpha := 1.0 if increase else 0.0

	# NOTE(vipa, 2024-10-02): Position chip particles
	var hp_pos: Control = hp_container.get_child((new_hdiff + max_health - 1) % max_health)
	chip_particles.global_position = hp_pos.global_position
	if current_chip_diff < 0:
		chip_particles.amount_ratio = - current_chip_diff / chip_size
	elif current_chip_diff >= 0:
		chip_particles.amount_ratio = 0

	# NOTE(vipa, 2024-10-02): Change full health things
	if last - first == 0:
		return

	var t := create_tween()
	var _ignore := t.set_parallel(true)
	for i in last - first:
		var idx := first + i
		if idx < max_health:
			# NOTE(vipa, 2024-09-24): Normal health
			var rect := hp_container.get_child(idx).get_child(0) as ColorRect
			var _i := t.tween_property(rect, "position", target_rel_pos, 0.2)
			_i = t.tween_property(rect, "color:a", target_alpha, 0.2)
		else:
			# NOTE(vipa, 2024-09-24): Overhealth
			var rect := hp_container.get_child(idx - max_health).get_child(1) as ColorRect
			var _i := t.tween_property(rect, "position", -target_rel_pos, 0.2)
			_i = t.tween_property(rect, "color:a", target_alpha, 0.2)
