@tool
class_name AbilityNodeProxy extends PanelContainer

const ANPScene = preload("res://addons/abilityeditor/ability_node_proxy.tscn")

@onready var root_container: VBoxContainer = %"RootContainer"
@onready var shown_name: Label = %"Name"
@onready var shown_icon: TextureRect = %"Icon"
@onready var inspector: GridContainer = %"Inspector"

var undo: EditorUndoRedoManager

var target: AbilityNode
var icons: Dictionary

enum Kind { Leaf, Seq, Par, Trigger }

func set_proxy_target(n: AbilityNode, i: Dictionary) -> void:
	icons = i
	if target:
		cleanup()
	target = n

	update_name()
	var script: Script = n.get_script()
	shown_icon.texture = icons[script.get_global_name()]
	target.renamed.connect(update_name)
	target.tree_exiting.connect(update_parent)
	target.child_order_changed.connect(update_self)

	var k: Kind
	if target is AbilitySeq:
		k = Kind.Seq
	elif target is AbilityParAll:
		k = Kind.Par
	elif target is AbilityParAny:
		k = Kind.Par
	elif target is AbilityTriggered:
		k = Kind.Trigger
	else:
		k = Kind.Leaf

	setup_kind(k, icons)

	setup_inspector()

func setup_kind(k: Kind, icons: Dictionary) -> void:
	match k:
		Kind.Leaf:
			theme_type_variation = &"LeafNode"
		Kind.Seq:
			theme_type_variation = &"SeqLike"
		Kind.Par:
			theme_type_variation = &"ParLike"
		Kind.Trigger:
			theme_type_variation = &"TriggerLike"
	var container: Container = HBoxContainer.new() if k == Kind.Par else VBoxContainer.new()
	root_container.add_child(container)
	for i in target.get_child_count():
		var c := target.get_child(i) as AbilityNode
		if not c:
			push_error("Non-AbilityNode child of AbilityNode: " + str(target.get_path()))
			continue
		var c_proxy := ANPScene.instantiate() as AbilityNodeProxy
		container.add_child(c_proxy)
		c_proxy.undo = undo
		c_proxy.set_proxy_target(c, icons)


func cleanup() -> void:
	shown_name.text = "<None>"
	if is_instance_valid(target):
		target.renamed.disconnect(update_name)
		target.tree_exiting.disconnect(update_parent)
		target.child_order_changed.disconnect(update_self)

	theme_type_variation = &"LeafNode"

	clear_inspector()

	while root_container.get_child_count() > 2:
		var c := root_container.get_child(2)
		c.queue_free()
		root_container.remove_child(c)

	target = null

func setup_inspector() -> void:
	for prop in target.get_property_list():
		if not (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.usage & PROPERTY_USAGE_EDITOR):
			continue
		var l := Label.new()
		l.text = prop.name.capitalize()
		inspector.add_child(l)
		match prop.type:
			TYPE_STRING, TYPE_STRING_NAME:
				var e := LineEdit.new()
				e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				e.text = target.get(prop.name)
				e.text_changed.connect(update_property.bind(prop.name))
				inspector.add_child(e)
			TYPE_BOOL:
				var e := CheckButton.new()
				e.button_pressed = target.get(prop.name)
				e.toggled.connect(update_property.bind(prop.name))
				inspector.add_child(e)
			TYPE_OBJECT:
				var unknown := Label.new()
				unknown.text = ("<%s>" % prop[&"class_name"]) if target.get(prop.name) else str(target.get(prop.name))
				inspector.add_child(unknown)
			_:
				var unknown := Label.new()
				unknown.text = "<%s>" % target.get(prop.name)
				inspector.add_child(unknown)
	pass

func clear_inspector() -> void:
	# TODO(vipa, 2024-09-13): Clear any signals
	for i in inspector.get_child_count():
		inspector.get_child(i).queue_free()

func _gui_input(event: InputEvent) -> void:
	if not target:
		return

	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			var sel := EditorInterface.get_selection()
			sel.clear()
			sel.add_node(target)

func update_name() -> void:
	if target:
		shown_name.text = target.name

func update_property(value: Variant, prop: StringName) -> void:
	if not is_instance_valid(target):
		return
	# TODO(vipa, 2024-09-13): This doesn't update the editor, which
	# kinda sucks
	undo.create_action("Set %s" % prop, UndoRedo.MergeMode.MERGE_ENDS)
	undo.add_undo_property(target, prop, target.get(prop))
	undo.add_do_property(target, prop, value)
	undo.commit_action()
	pass

func update_self() -> void:
	if is_instance_valid(target):
		set_proxy_target(target, icons)
	else:
		cleanup()

func update_parent() -> void:
	var p := get_parent() as AbilityNodeProxy
	if p:
		p.update_self()
