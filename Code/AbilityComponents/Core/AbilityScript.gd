class_name AbilityScript extends Resource

## Callback to construct the actual tree representing this ability.
func _ability() -> AbilityNode:
	assert(false, "An AbilityScript must override _ability")
	return null

func init_node(n: AbilityNode, config: Dictionary, children: Array[AbilityNode]) -> AbilityNode:
	var props := n.get_property_list()
	var pmap := {}
	for p in props:
		pmap[p.name] = p
	for k: StringName in config:
		if not pmap.has(k):
			push_error("Bad key for AbilityNode: %s" % k)
			continue

		var prop: Dictionary = pmap[k]
		if typeof(config[k]) == prop.type or (typeof(config[k]) == TYPE_STRING and prop.type == TYPE_STRING_NAME):
			n.set(k, config[k])
		elif prop.hint & PROPERTY_HINT_EXPRESSION:
			n.set(k, str(config[k]))
		else:
			push_error("Bad value for AbilityNode, %s does not match %s" % [config[k], prop])
	if not children.is_empty():
		assert(n is AbilitySeq or n is AbilityParAll or n is AbilityParAny or n is AbilityTriggered or n is AbilityFailover, "Ability script added children to ability node that did not expect any.\nresource: %s\nnode: %s" % [resource_path, n])
		for c in children:
			n.add_child(c)
	return n

# Core

func seq(a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return _seq(res.filter(func(a: AbilityNode) -> bool: return a != null))
func _seq(children: Array[AbilityNode]) -> AbilityNode:
	return init_node(AbilitySeq.new(), {}, children)

func any(a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return _any(res.filter(func(a: AbilityNode) -> bool: return a != null))
func _any(children: Array[AbilityNode]) -> AbilityNode:
	return init_node(AbilityParAny.new(), {}, children)

func all(a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return _all(res.filter(func(a: AbilityNode) -> bool: return a != null))
func _all(children: Array[AbilityNode]) -> AbilityNode:
	return init_node(AbilityParAll.new(), {}, children)

func failover(a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return _failover(res.filter(func(a: AbilityNode) -> bool: return a != null))
func _failover(children: Array[AbilityNode]) -> AbilityNode:
	return init_node(AbilityFailover.new(), {}, children)

func if_cont(condition: String, a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var ret := Conditional.new()
	ret.condition = condition
	ret.continuous = true
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return init_node(ret, {}, res.filter(func(a: AbilityNode) -> bool: return a != null))

func if_once(condition: String, a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var ret := Conditional.new()
	ret.condition = condition
	ret.continuous = false
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return init_node(ret, {}, res.filter(func(a: AbilityNode) -> bool: return a != null))

func cancellable(a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return _cancellable(res.filter(func(a: AbilityNode) -> bool: return a != null))
func _cancellable(children: Array[AbilityNode]) -> AbilityNode:
	return init_node(Cancellable.new(), {}, children)

# Effects

func write(property: StringName, data: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := WriteToBlackboard.new()
	ret.property = property
	ret.source = data
	return init_node(ret, extra, [])

func timer(duration: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := AbilityTimer.new()
	ret.duration = duration
	return init_node(ret, extra, [])

func alter_health(amount: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := AlterHealth.new()
	ret.amount = amount
	return init_node(ret, extra, [])

func destroy_self() -> AbilityNode:
	return DestroySelf.new()

func create_effect(effect: PackedScene, extra: Dictionary = {}) -> AbilityNode:
	var ret := CreateEffect.new()
	ret.effect = effect
	return init_node(ret, extra, [])

func move(target: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := MoveCharacter.new()
	ret.target = target
	return init_node(ret, extra, [])

func teleport(position: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := TeleportCharacter.new()
	ret.position = position
	return init_node(ret, extra, [])

func play_animation(animation: AnimatedUnit.A, extra: Dictionary = {}) -> AbilityNode:
	var ret := PlayAnimation.new()
	ret.animation = animation
	return init_node(ret, extra, [])

func character_state(options: Dictionary) -> AbilityNode:
	return init_node(CharacterState.new(), options, [])

func run_ability(ability: AbilityScript, extra: Dictionary) -> AbilityNode:
	var ret := RunAbility.new()
	ret.ability = ability
	return init_node(ret, extra, [])

func visual_offset(target: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := VisualOffset.new()
	ret.target = target
	return init_node(ret, extra, [])

func spawn_unit(unit: PackedScene, point: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := SpawnUnit.new()
	ret.unit = unit
	ret.point = point
	return init_node(ret, extra, [])

func rotate(target: String, extra: Dictionary = {}) -> AbilityNode:
	var ret := RotateCharacter.new()
	ret.target = target
	return init_node(ret, extra, [])

func telegraph(options: Dictionary) -> AbilityNode:
	return init_node(ATelegraph.new(), options, [])

# Effects with children

func shapecast(shape: Shape2D, options: Dictionary, a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return _shapecast(shape, options, res.filter(func(a: AbilityNode) -> bool: return a != null))
func _shapecast(shape: Shape2D, options: Dictionary, children: Array[AbilityNode] = []) -> AbilityNode:
	var ret := ShapeCast.new()
	ret.shape = shape
	return init_node(ret, options, children)

func on_altered_health(new_delta: String = "delta", options: Dictionary = {}, a1: AbilityNode = null, a2: AbilityNode = null, a3: AbilityNode = null, a4: AbilityNode = null, a5: AbilityNode = null, a6: AbilityNode = null, a7: AbilityNode = null, a8: AbilityNode = null, a9: AbilityNode = null) -> AbilityNode:
	var res: Array[AbilityNode] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]
	return _on_altered_health(new_delta, options, res.filter(func(a: AbilityNode) -> bool: return a != null))
func _on_altered_health(new_delta: String, options: Dictionary, children: Array[AbilityNode] = []) -> AbilityNode:
	var ret := OnAlteredHealth.new()
	ret.new_delta = new_delta
	return init_node(ret, options, children)
