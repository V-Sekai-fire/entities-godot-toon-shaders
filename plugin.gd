@tool
extends EditorPlugin
## Registers the lilToon and SCSS material inspectors (modeled on the MToon one).
## MToon's own inspector ships with mtoon/ (its vendored Godot-MToon-Shader
## plugin), so it is not re-registered here.

const LilToonInspector = preload("liltoon/inspector_liltoon.gd")
const SCSSInspector = preload("scss/inspector_scss.gd")

var _liltoon: EditorInspectorPlugin = null
var _scss: EditorInspectorPlugin = null


func _enter_tree() -> void:
	_liltoon = LilToonInspector.new()
	_scss = SCSSInspector.new()
	add_inspector_plugin(_liltoon)
	add_inspector_plugin(_scss)


func _exit_tree() -> void:
	if _liltoon != null:
		remove_inspector_plugin(_liltoon)
	if _scss != null:
		remove_inspector_plugin(_scss)
