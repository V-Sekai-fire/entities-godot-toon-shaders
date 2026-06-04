@tool
extends ToonShaderInspector
## lilToon inspector — metadata only; the grouped UI machinery lives in the
## shared ToonShaderInspector base (modeled on Godot-MToon-Shader's inspector).

func _shader_match(path: String) -> bool:
	return path.find("/liltoon") != -1


func headers() -> Dictionary:
	return {
		"_Color": "Main Color",
		"_ShadowColor": "Shading",
		"_RimColor": "Rim Light",
		"_EmissionColor": "Emission",
		"_OutlineWidthMode": "Outline",
	}


func color_params() -> Array:
	return ["_Color", "_ShadowColor", "_RimColor", "_EmissionColor", "_OutlineColor"]


func enum_params() -> Dictionary:
	return {"_OutlineWidthMode": ["None", "World", "Screen"]}


func ranges() -> Dictionary:
	return {
		"_Cutoff": [0.0, 1.0, 0.001],
		"_BumpScale": [0.0, 2.0, 0.001],
		"_ShadowBorder": [0.0, 1.0, 0.001],
		"_ShadowBlur": [0.0, 1.0, 0.001],
		"_RimFresnelPower": [0.0, 100.0, 0.01],
		"_OutlineWidth": [0.0, 1.0, 0.001],
	}


func defaults() -> Dictionary:
	return {
		"_Color": Color(1, 1, 1, 1),
		"_ShadowColor": Color(0.82, 0.76, 0.85, 1.0),
		"_ShadowBorder": 0.5,
		"_ShadowBlur": 0.1,
		"_RimFresnelPower": 3.0,
		"_BumpScale": 1.0,
		"_Cutoff": 0.5,
	}


func labels() -> Dictionary:
	return {
		"_Color": ["Lit Color, Alpha", "Base color (RGB) and alpha (A)."],
		"_MainTex": ["Lit Texture", "Base color texture."],
		"_Cutoff": ["Alpha Cutoff", "Discard pixels below this alpha in cutout mode."],
		"_BumpMap": ["Normal Map", "Tangent-space normal map."],
		"_BumpScale": ["Normal Scale", "Normal map strength."],
		"_ShadowColor": ["Shadow Color", "1st shade color (lilToon _ShadowColor)."],
		"_ShadowBorder": ["Shadow Border", "Lit/shade boundary (lilToon _ShadowBorder)."],
		"_ShadowBlur": ["Shadow Blur", "Softness of the shade boundary (lilToon _ShadowBlur)."],
		"_RimColor": ["Rim Color", "Fresnel rim color (RGB); alpha scales strength."],
		"_RimFresnelPower": ["Rim Power", "Higher = sharper rim."],
		"_EmissionColor": ["Emission", "Emission color (RGB)."],
		"_EmissionMap": ["Emission Map", "Emission texture."],
		"_OutlineWidthMode": ["Width Mode", "Outline width space. None disables the outline (scaffold)."],
		"_OutlineWidth": ["Outline Width", "Outline thickness (scaffold)."],
		"_OutlineColor": ["Outline Color", "Outline color (scaffold)."],
		"_MatCapTex": ["MatCap", "Additive sphere / matcap texture (reference)."],
	}
