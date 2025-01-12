extends Camera2D

@export var shake_max_range := 1000.0
@export var shake_range_falloff : Curve

@export var shake_speed := 100.0
@export var shake_pos_magnitude_max := 50.0
@export var shake_rot_magnitude_max := PI/10

@export var shake_dissipation_speed := 0.33

@export var shake_noise : FastNoiseLite

var trauma := 0.0
var t := 0.0

## Strength will be capped at 1.0 after adding
func add_shake(pos: Vector2, strength: float) -> void:
	_do_add_shake.rpc(pos, strength)

@rpc("unreliable", "call_local")
func _do_add_shake(pos: Vector2, strength: float) -> void:
	var dist_sq := pos.distance_squared_to(position)
	if dist_sq > shake_max_range * shake_max_range:
		return

	var dist := sqrt(dist_sq)

	trauma = minf(trauma + strength * shake_range_falloff.sample(dist / shake_max_range), 1.0)

func _process(delta: float) -> void:
	shake_noise.seed = 0
	offset.x = shake_pos_magnitude_max * pow(trauma, 1.5) * shake_noise.get_noise_1d(t * shake_speed)
	shake_noise.seed = 1
	offset.y = shake_pos_magnitude_max * pow(trauma, 1.5) * shake_noise.get_noise_1d(t * shake_speed)
	shake_noise.seed = 2
	rotation = shake_rot_magnitude_max * pow(trauma, 1.5) * shake_noise.get_noise_1d(t * shake_speed)
	trauma -= minf(shake_dissipation_speed * delta, trauma)
	t += delta
