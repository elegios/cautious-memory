class_name PlayerAbilities extends Node

signal move_cancelled

signal move_issued(target: Vector2)
signal move_to_unit_issued(target: Node2D)

var controller: int:
	set(value):
		controller = value
		var abi_cont := %"AbilityContainer" as Control
		if abi_cont:
			abi_cont.visible = value == multiplayer.get_unique_id()

@export var runner : AbilityRunner

@onready var cast : ShapeCast2D = %"ShapeCast"

@export var ability_icon : PackedScene

## The abilities directly usable by this player character. Index 0 is
## the auto-attack.
@export var abilities : Array[PlayerAbility]

# NOTE(vipa, 2024-10-07): cd remaining in seconds
var cooldowns : Array[float]
var charge_cooldowns : Array[float]
var charges : Array[int]
var ability_icons : Array[AbilityIcon]

## The ability queued for use. Will execute when in range (checking
## every frame).
var issued_action := -1
var issued_bb : Blackboard = null

func _ready() -> void:
	cooldowns = []
	charge_cooldowns = []
	charges = []
	for i in abilities.size():
		cooldowns.push_back(0)
		charge_cooldowns.push_back(0)
		charges.push_back(abilities[i].max_charges)

		var abi_i: AbilityIcon = ability_icon.instantiate()
		abi_i.tooltip_text = abilities[i].description
		%"AbilityContainer".add_child(abi_i)
		ability_icons.push_back(abi_i)

## Try to run an ability, sending a soft interrupt to the currently
## running main ability, if one exists. Fails if:
## - No charge is available/the ability is on cooldown
## - The main ability did not acknowledge the interrupt
func try_run_ability(id: int, pos: Vector2) -> void:
	_cancel_issued_action()
	if charges[id] == 0 or cooldowns[id] > 0:
		return

	var abi := abilities[id]

	var target_unit: Node2D = null
	var target_point := Vector2.ZERO

	if abi.unit_filter:
		cast.global_position = pos
		cast.collision_mask = abi.unit_filter
		var c := cast.shape as CircleShape2D
		if not c:
			c = CircleShape2D.new()
			cast.shape = c
		c.radius = abi.unit_target_radius
		cast.force_shapecast_update()
		if cast.is_colliding():
			var t: Node2D = null
			var dist := 10000000.0
			for i in cast.get_collision_count():
				var new_t := cast.get_collider(i) as Node2D
				var new_dist := new_t.position.distance_squared_to(pos)
				if new_dist < dist:
					t = new_t
					dist = new_dist
			target_unit = t

	if not target_unit and not abi.can_target_point:
		return

	target_point = target_unit.position if target_unit else pos

	if abi.max_range > 0:
		if target_point.distance_squared_to(runner.character.position) <= abi.max_range*abi.max_range:
			pass

		elif abi.walk_in_range:
			if not abi.is_main or runner.try_soft_interrupt():
				issued_action = id
				issued_bb = Blackboard.new(runner.unit_spawner)
				if target_unit:
					print("walking towards target unit")
					issued_bb.bset(&"target_unit", target_unit)
					move_to_unit_issued.emit(target_unit)
				else:
					print("walking towards target point")
					issued_bb.bset(&"target_point", target_point)
					move_issued.emit(target_point)
			return

		elif abi.can_target_point:
			target_point = runner.character.position + (target_point - runner.character.position).limit_length(abi.max_range)

		else:
			return

	var bb := Blackboard.new(runner.unit_spawner)
	if target_unit:
		bb.bset(&"target_unit", target_unit)
	else:
		bb.bset(&"target_point", target_point)

	_actually_cast_ability(id, bb)

func _actually_cast_ability(id: int, bb: Blackboard) -> void:
	_cancel_issued_action()
	if multiplayer and not multiplayer.is_server():
		return

	if id < 0:
		push_error("bad id: " + str(id))

	var abi := abilities[id]
	var bb_state := []
	bb.save_state(bb_state)

	var config := {
		&"path": abi.ability.resource_path,
		&"is_main": abi.is_main,
		&"blackboard": bb_state,
	}

	var success := runner.try_run_custom_ability(config, AbilityNode.AInterruptKind.Soft)

	if success:
		cooldowns[id] = abi.cooldown
		if abi.charge_cooldown > 0:
			charges[id] -= 1
			if charge_cooldowns[id] <= 0:
				charge_cooldowns[id] = abi.charge_cooldown

		if abi.cancel_move:
			move_cancelled.emit()

func _physics_process(delta: float) -> void:
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, cooldowns[i] - delta)

	for i in charge_cooldowns.size():
		if charge_cooldowns[i] <= 0:
			continue
		charge_cooldowns[i] -= delta
		if charge_cooldowns[i] <= 0:
			charges[i] += 1
			if charges[i] < abilities[i].max_charges:
				charge_cooldowns[i] = abilities[i].charge_cooldown

	for i in ability_icons.size():
		var abi_i := ability_icons[i]
		abi_i.charges = charges[i]
		var cd_remaining := cooldowns[i]
		var cd_max := abilities[i].cooldown
		if charges[i] == 0 and charge_cooldowns[i] > cd_remaining:
			cd_remaining = charge_cooldowns[i]
			cd_max = abilities[i].charge_cooldown
		abi_i.cd_remaining = cd_remaining
		abi_i.cd_max = cd_max

	if issued_action >= 0 and issued_bb:
		var unit: Variant = issued_bb.bget(&"target_unit", true)
		var point: Variant = issued_bb.bget(&"target_point", true)
		var max_range := abilities[issued_action].max_range
		if unit is Node2D:
			var u: Node2D = unit
			if u.position.distance_squared_to(runner.character.position) < max_range*max_range:
				print("reached unit")
				_actually_cast_ability(issued_action, issued_bb)
		elif point is Vector2:
			var p: Vector2 = point
			if p.distance_squared_to(runner.character.position) < max_range*max_range:
				print("reached point")
				_actually_cast_ability(issued_action, issued_bb)
		else:
			# NOTE(vipa, 2024-10-10): target has disappeared, cancel
			# order
			_cancel_issued_action()

func _cancel_issued_action() -> void:
	issued_action = -1
	issued_bb = null

func _on_move_command(_target: Vector2) -> void:
	_cancel_issued_action()
