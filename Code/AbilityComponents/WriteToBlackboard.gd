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
@export var source: DataSource

func setup(a: AbilityRunner, b: Blackboard) -> void:
	if source:
		source = source.setup(a, b)
	super(a, b)

func save_state(buffer: Array) -> void:
	if source:
		source.save_state(buffer)

func load_state(buffer: Array, idx: int) -> int:
	if source:
		idx = source.load_state(buffer, idx)
	return idx

func pre_first_process() -> void:
	if source:
		source.pre_first_data()

func physics_process_ability(delta: float) -> ARunResult:
	if source:
		blackboard.bset(property, source.get_data(delta))
	else:
		blackboard.bclear(property)
	return ARunResult.Done
