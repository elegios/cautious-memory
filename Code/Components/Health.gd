## Interface for things with health.
class_name Health extends Node

signal health_increased(amount: float)
signal health_decreased(amount: float)

## A set of Callables, each of which should take and return a health
## delta. Can be used to alter the amount of damage/healing done, as
## well as react to taking damage.
@onready var modifiers: Array[Callable] = []

## Change the amount of health of this unit. Negative delta means
## damage, positive delta means healing. Returns the actual delta
## after modifications by abilities and capping by min/max health.
func alter_health(delta: float) -> float:
	for m in modifiers:
		delta = m.call(delta)
	var res := _alter_health(delta)
	if res < 0:
		health_decreased.emit(-res)
	if res > 0:
		health_increased.emit(res)
	return res

## Callback to actually make the change. Should return the actual
## delta after capping by min/max health.
func _alter_health(delta: float) -> float:
	return delta

## Register a modifier to alter health changes.
func register_modifier(m: Callable) -> void:
	if not modifiers.has(m):
		modifiers.push_back(m)

func unregister_modifier(m: Callable) -> void:
	modifiers.erase(m)
