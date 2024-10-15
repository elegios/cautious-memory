@tool
extends EditorPlugin

const AnimationImporter = preload("animation_importer.gd")
const MapImporter = preload("map_importer.gd")

var imp1: AnimationImporter
var imp2: MapImporter

func _enter_tree() -> void:
	var editor := get_editor_interface()
	imp1 = AnimationImporter.new(editor)
	imp2 = MapImporter.new()
	add_import_plugin(imp1)
	add_import_plugin(imp2)


func _exit_tree() -> void:
	remove_import_plugin(imp1)
	remove_import_plugin(imp2)
	imp1 = null
	imp2 = null
