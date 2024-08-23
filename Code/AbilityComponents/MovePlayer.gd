## Move a player in a given direction.
class_name MovePlayer extends AbilityNode

## A vector denoting the direction to move in, in pixels per
## second. Note that the vector will [i]not[/i] be normalized before
## being applied.
@export var direction: DataSource
## A scaling factor to be applied to the direction. Defaults to '1' if
## absent.
@export var factor: DataSource

func physics_process_ability(_delta: float) -> ARunResult:
	var dir: Vector2 = direction.get_data(player, blackboard)
	var scale: float = factor.get_data(player, blackboard) if factor else 1.0
	player.velocity = scale * dir
	var _hit := player.move_and_slide()
	return ARunResult.Wait
