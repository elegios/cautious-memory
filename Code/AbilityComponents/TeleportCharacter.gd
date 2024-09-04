## Instantly change the position of a character, possibly
## continuously.
class_name TeleportCharacter extends AbilityNode

## Continuously update character position. Finishes after the first
## position update if false, otherwise keeps updating position until
## interrupted.
@export var continuous: bool = false

## Position to set the character to.
@export var position: DataSource

func setup(a: AbilityRunner, b: Blackboard) -> void:
	position = position.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	position.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	return position.load_state(buffer, idx)

func pre_first_process() -> void:
	position.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	runner.character.position = position.get_data(delta)
	return ARunResult.Wait if continuous else ARunResult.Done
