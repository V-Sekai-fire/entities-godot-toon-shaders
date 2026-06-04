@tool
extends EditorInspectorPlugin
class_name ToonShaderInspector
## Reusable, metadata-driven inspector for avatar toon shaders — the generic core
## distilled from Godot-MToon-Shader's inspector_mtoon.gd. A concrete inspector
## (lilToon, SCSS) subclasses this and overrides the metadata hooks below; the
## base renders the grouped UI: section headers, color pickers, ranged sliders,
## enum dropdowns, and per-parameter tooltips, modeled on the MToon inspector.

# ---- metadata hooks (override in subclasses) -------------------------------
func _shader_match(_path: String) -> bool: return false  # true if this is "my" shader
func headers() -> Dictionary: return {}      # param -> section header drawn above it
func labels() -> Dictionary: return {}       # param -> [display_label, tooltip]
func color_params() -> Array: return []      # params edited as a Color swatch
func enum_params() -> Dictionary: return {}  # param -> [option strings]
func ranges() -> Dictionary: return {}       # param -> [min, max, step]  (step 0 = free)
func defaults() -> Dictionary: return {}     # param -> default value when unset

var _editors: Dictionary = {}
var _first: EditorProperty = null


func _can_handle(object: Object) -> bool:
	return object is ShaderMaterial and object.shader != null and _shader_match(object.shader.resource_path)


func _parse_property(object: Object, type, path: String, _hint, hint_text: String, _usage, _wide) -> bool:
	if not str(path).begins_with("shader_parameter/"):
		return false
	var param: String = str(path).split("/")[-1]
	var lbl: Array = labels().get(param, [param, ""])
	var editor: EditorProperty = null
	if color_params().has(param):
		editor = ColorProp.new(lbl[1], type == TYPE_COLOR)
	elif enum_params().has(param):
		editor = EnumProp.new(lbl[1], enum_params()[param])
	elif type == TYPE_OBJECT and str(hint_text).find("Texture") != -1:
		return false  # leave Godot's native texture picker in place
	elif type == TYPE_INT or type == TYPE_FLOAT:
		var r: Array = ranges().get(param, [0.0, 1.0, 0.001])
		editor = SpinProp.new(lbl[1], r[0], r[1], r[2])
	else:
		return false
	editor.edited_object = object
	editor.default_value = defaults().get(param, null)
	_editors[param] = editor
	if _first == null:
		_first = editor
	add_property_editor_for_multiple_properties(lbl[0], PackedStringArray([path]), editor)
	return true


func _parse_end(_object: Object) -> void:
	if _first != null:
		var vbox: Control = _first.get_parent()
		for param in headers():
			var ed: Control = _editors.get(param)
			if ed != null:
				var header: Control = _make_header(headers()[param])
				vbox.add_child(header)
				vbox.move_child(header, vbox.get_children().find(ed))
		var section: Object = vbox.get_parent()
		if section != null and section.has_method("unfold"):
			section.unfold()
	_editors = {}
	_first = null


func _make_header(text: String) -> Control:
	var hbox: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	label.text = text
	label.scale = Vector2(1.12, 1.05)
	var c: Color = label.get_theme_color("font_color")
	label.add_theme_color_override("font_color", Color(round(c.r), round(c.g), round(c.b), 1.0))
	hbox.add_child(label)
	return hbox


# ---- reusable EditorProperty classes (modeled on inspector_mtoon.gd) --------
class BaseProp:
	extends EditorProperty
	var edited_object: ShaderMaterial = null
	var default_value = null
	var updating: bool = false
	var tooltip: String = ""

	func _make_custom_tooltip(_for_text: String) -> Object:
		var l: Label = Label.new()
		l.text = tooltip
		l.custom_minimum_size = Vector2(220, 30)
		return l

	func _cur() -> Variant:
		var v: Variant = edited_object[get_edited_property()]
		return default_value if typeof(v) == TYPE_NIL else v

	func _set_param(val: Variant) -> void:
		edited_object[get_edited_property()] = val


class ColorProp:
	extends BaseProp
	var picker: ColorPickerButton = ColorPickerButton.new()

	func _init(tip: String, alpha: bool) -> void:
		tooltip = tip
		picker.edit_alpha = alpha
		picker.custom_minimum_size = Vector2(40, 30)
		add_child(picker)
		add_focusable(picker)
		picker.color_changed.connect(_on_changed)

	func _on_changed(c: Color) -> void:
		if not updating:
			_set_param(c)

	func _update_property() -> void:
		var v: Variant = _cur()
		if typeof(v) != TYPE_COLOR:
			v = Color(1, 1, 1, 1)
		updating = true
		picker.color = v
		updating = false


class SpinProp:
	extends BaseProp
	var spin: EditorSpinSlider = EditorSpinSlider.new()

	func _init(tip: String, mn: float, mx: float, st: float) -> void:
		tooltip = tip
		spin.min_value = mn
		spin.max_value = mx
		spin.step = abs(st) if st != 0.0 else 0.001
		spin.allow_lesser = st == 0.0
		spin.allow_greater = st == 0.0
		spin.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(spin)
		add_focusable(spin)
		spin.value_changed.connect(_on_changed)

	func _on_changed(v: float) -> void:
		if not updating:
			_set_param(v)

	func _update_property() -> void:
		var v: Variant = _cur()
		if typeof(v) == TYPE_NIL:
			v = 0.0
		updating = true
		spin.value = v
		updating = false


class EnumProp:
	extends BaseProp
	var dropdown: OptionButton = OptionButton.new()

	func _init(tip: String, options: Array) -> void:
		tooltip = tip
		for o in options:
			dropdown.add_item(str(o))
		add_child(dropdown)
		add_focusable(dropdown)
		dropdown.item_selected.connect(_on_selected)

	func _on_selected(idx: int) -> void:
		if not updating:
			_set_param(idx)

	func _update_property() -> void:
		var v: Variant = _cur()
		if typeof(v) == TYPE_NIL:
			v = 0
		updating = true
		dropdown.selected = int(v)
		updating = false
