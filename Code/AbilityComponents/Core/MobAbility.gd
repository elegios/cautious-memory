@tool
class_name MobAbility extends Resource

## Whether the ability should be a main ability. If true, requires the
## current main ability (if any) to acknowledge a soft
## interrupt. Always succeeds if false.
@export var is_main : bool = true

## The cooldown of this ability, in seconds.
@export var cooldown : float = 2.0

## Optional. All of these conditions must be true to run the
## ability. Short-circuiting, i.e., if the first condition fails, then
## the second isn't even checked.
