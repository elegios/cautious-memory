## Instantly change the position of a character, possibly
## continuously.
class_name TeleportCharacter extends AbilityNode

## Continuously update character position. Finishes after the first
## position update if false, otherwise keeps updating position until
## interrupted.
@export var continuous: bool = false

## Position to set the character to.
@export var position: DataSource

func register_properties(root: AbilityRoot) -> void:
	position.register_properties(self, "position", root)

func setup(a: AbilityRunner, r: AbilityRoot, b: Dictionary, register_props: bool) -> void:
	position.setup(a, b)
	super(a, r, b, register_props)

func physics_process_ability(delta: float) -> ARunResult:
	runner.character.position = position.get_data(delta)
	return ARunResult.Wait if continuous else ARunResult.Done
