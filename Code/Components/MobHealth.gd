extends Health

signal health_depleted

## Maximum amount of health.
@export var max_health := 10.0

## Current health. Death happens at zero.
@onready var health := max_health:
	set(value):
		if value == health:
			return
		health = clampf(value, 0, max_health)
		if real_bar:
			real_bar.value = health / max_health * delayed_bar.max_value
			timer.stop()
			timer.start()

@onready var real_bar: ProgressBar = %"CorrectHealth"
@onready var delayed_bar: ProgressBar = %"DelayedHealth"
@onready var timer: Timer = %"Timer"

func _alter_health(delta: float) -> float:
	var prev := health
	health += delta
	if is_zero_approx(health) and multiplayer.is_server():
		health_depleted.emit()
	return health - prev

func _on_timer_timeout() -> void:
	delayed_bar.value = health / max_health * delayed_bar.max_value
