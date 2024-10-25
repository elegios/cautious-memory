@tool
class_name PlayerSpawner extends Node2D

## The time between a player being destroyed and them
## respawning.
@export var respawn_time: float = 5.0

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
		push_warning("No spawner found, cannot spawn players")
		return

	var _ignore := PlayerData.character_chosen.connect(_late_spawn)
	_ignore = multiplayer.peer_connected.connect(_on_peer_connect)

	_on_peer_connect(1)
	for id in multiplayer.get_peers():
		_on_peer_connect(id)

func _on_peer_connect(id: int) -> void:
	var scene := PlayerData.get_character(id)
	if scene:
		_spawn(id, scene)
	else:
		PlayerData.request_choice(id)

func _late_spawn(id: int) -> void:
	_spawn(id, PlayerData.get_character(id))

func _spawn(id: int, scene: PackedScene) -> void:
	var point := position
	if spawn_area:
		var circle := spawn_area as CircleShape2D
		var rectangle := spawn_area as RectangleShape2D
		if circle:
			var angle := randf_range(0, 2*PI)
			var distance := randf_range(0, circle.radius)
			point += Vector2.from_angle(angle) * distance
		elif rectangle:
			var x := (randf() - 0.5) * rectangle.size.x
			var y := (randf() - 0.5) * rectangle.size.y
			point += Vector2(x, y)
		else:
			push_error("Unsupported player spawning shape: " + str(spawn_area))
	var unit : Player = unit_spawner.spawn_unit(scene, point)
	unit.controller = id
	if respawn_time > 0.0:
		var _ignore := unit.tree_exited.connect(_queue_respawn.bind(id))

func _queue_respawn(id: int) -> void:
	var tree := get_tree()
	# NOTE(vipa, 2024-09-19): Guard on this in case we're in the
	# process of destroying everything, in which case we don't want to
	# respawn things
	if tree:
		var _ignore := tree.create_timer(respawn_time, false).timeout.connect(_late_spawn.bind(id))
