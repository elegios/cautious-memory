@icon("../Icons/Edit.svg")
## Write a value (computed via a [DataSource]) to the blackboard.
class_name WriteToBlackboard extends AbilityNode

## The property to be overwritten. If the property is prefixed by
## [code]m_[/code], then it will be persisted on the unit between
## ability runs. There are three important points about such properties:
##
## 1. Previously stored [code]m_[/code] properties are snapshotted
##    when an ability starts.
## 2. Updated [code]m_[/code] properties are persisted when the
##    ability ends, and no sooner.
## 3. Only [i]modified[/i] [code]m_[/code] properties are persisted.
##
## The sum total of these things is that it's very much possible to
## get data race-like behaviour when using [code]m_[/code] properties
## in abilities that run in parallel.
@export var property: StringName

## The value to write. Will clear the property if absent.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var source: String
@onready var source_e: Expression = parse_expr(source) if source else null

func physics_process_ability(_delta: float, _first: bool) -> ARunResult:
	if source_e:
		var res := run_expr(source, source_e)
		if res.err == Err.ShouldBail:
			return ARunResult.Error
		blackboard.bset(property, res.value)
	else:
		blackboard.bclear(property)
	return ARunResult.Done
