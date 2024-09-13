@tool
extends EditorPlugin


const MainPanel = preload("res://addons/abilityeditor/main_panel.tscn")

var main_panel_instance: Control

var root_node_proxy: AbilityNodeProxy

var class_to_icon: Dictionary = {}


func _enter_tree():
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

	root_node_proxy = main_panel_instance.get_node("%Root Node")
	root_node_proxy.undo = get_undo_redo()
	scene_changed.connect(_on_scene_changed)

	class_to_icon.clear()
	var theme := EditorInterface.get_editor_theme()
	for c in ProjectSettings.get_global_class_list():
		if c.icon:
			class_to_icon[c[&"class"]] = ResourceLoader.load(c.icon)
		elif class_to_icon.has(c.base):
			class_to_icon[c[&"class"]] = class_to_icon[c.base]
		elif theme.has_icon(c.base, "EditorIcons"):
			class_to_icon[c[&"class"]] = theme.get_icon(c.base, "EditorIcons")
		else:
			class_to_icon[c[&"class"]] = theme.get_icon("Node", "EditorIcons")


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	main_panel_instance = null


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "Ability Editor"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func _handles(o: Object) -> bool:
	return o is AbilityNode

func _on_scene_changed(n: Node) -> void:
	var an := n as AbilityNode
	if an:
		root_node_proxy.set_proxy_target(an, class_to_icon)
	else:
		root_node_proxy.cleanup()

# NOTE(vipa, 2024-09-13): _get_state and _set_state should save pan and such
