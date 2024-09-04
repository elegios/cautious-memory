class_name PlayerAbility extends Resource

## Whether the ability should be a main ability. If true, requires the
## current main ability (if any) to acknowledge a soft
## interrupt. Always succeeds if false.
@export var is_main : bool = true

## Whether movement should be cancelled when the ability is
## activated. If [code]cancel_move[/code] is false and
## [code]is_main[/code] is true, then movement is merely paused while
## the ability runs.
@export var cancel_move : bool = true

## The ability to run.
@export var ability : PackedScene
