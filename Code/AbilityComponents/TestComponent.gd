class_name TestComponent extends AbilityNode

func physics_process_ability(_delta: float) -> ARunResult:
	player.collision_mask &= ~1
	player.collision_layer &= ~1
	var coll := player.get_last_slide_collision()
	if coll:
		print(coll.get_collider())
		print(coll.get_collider() as Player)
	else:
		print("no collision")
	return ARunResult.Wait

func process_ability(_delta: float) -> ARunResult:
	return ARunResult.Wait

func interrupt(kind: AInterruptKind) -> AInterruptResult:
	match kind:
		AInterruptKind.Hard, AInterruptKind.Counter:
			player.collision_mask |= 1
			player.collision_layer |= 1
			return AInterruptResult.Interrupted
		AInterruptKind.Soft:
			return AInterruptResult.Uninterrupted
		_:
			assert(false, "Impossible")
			return AInterruptResult.Interrupted
