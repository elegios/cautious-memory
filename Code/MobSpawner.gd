@tool
class_name MobSpawner extends Node2D

## The number of mobs to spawn.
@export var count: int = 1

## The time between a mob being destroyed and a new one
## spawning. Respawning is disabled if non-positive.
@export var respawn_time: float = 0.0

## The mob to spawn.
@export var mob: PackedScene

## The mob is spawned at a random point within this area.
@export var spawn_area: Shape2D:
	set(value):
		if spawn_area == value:
			return
		if spawn_area != null and spawn_area.changed.is_connected(queue_redraw):
			spawn_area.changed.disconnect(queue_redraw)
		spawn_area = value
		if spawn_area != null and not spawn_area.changed.is_connected(queue_redraw):
			var _ignore := spawn_area.changed.connect(queue_redraw)
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	if spawn_area == null:
		return

	spawn_area.draw(get_canvas_item(), Color.TRANSPARENT)

var unit_spawner: UnitSpawner

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if multiplayer.is_server():
		_initial_setup.call_deferred()

func _initial_setup() -> void:
	unit_spawner = get_tree().get_first_node_in_group(&"spawners")

	if not unit_spawner:
		push_warning("No spawner found, cannot spawn mobs")
		return

	for _i in count:
		_spawn_one()

func _spawn_one() -> void:
	var point := position
	if spawn_area:
		var circle := spawn_area as CircleShape2D
		if circle:
			var angle := randf_range(0, 2*PI)
			var distance := randf_range(0, circle.radius)
			point += Vector2.from_angle(angle) * distance
	var unit := unit_spawner.spawn_unit(mob, point)
	if respawn_time > 0.0:
		var _ignore := unit.tree_exited.connect(_queue_respawn)

func _queue_respawn() -> void:
	var _ignore := get_tree().create_timer(respawn_time, false).timeout.connect(_spawn_one)
