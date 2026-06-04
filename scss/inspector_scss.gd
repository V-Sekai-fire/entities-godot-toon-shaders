@tool
extends ToonShaderInspector
## SCSS (Silent's Cel Shading Shader) inspector — metadata only; the grouped UI
## machinery lives in the shared ToonShaderInspector base (modeled on the
## Godot-MToon-Shader inspector).

func _shader_match(path: String) -> bool:
	return path.find("/scss") != -1


func headers() -> Dictionary:
	return {
		"_Color": "Main Color",
		"_1st_ShadeColor": "Shading",
		"_RimColor": "Rim Light",
		"_EmissionColor": "Emission",
		"_OutlineMode": "Outline",
	}


func color_params() -> Array:
	return ["_Color", "_1st_ShadeColor", "_RimColor", "_EmissionColor", "_Outline_Color"]


func enum_params() -> Dictionary:
	return {"_OutlineMode": ["None", "World", "Screen"]}


func ranges() -> Dictionary:
	return {
		"_Cutoff": [0.0, 1.0, 0.001],
		"_BumpScale": [0.0, 2.0, 0.001],
		"_BaseColor_Step": [0.0, 1.0, 0.001],
		"_BaseShade_Feather": [0.0, 1.0, 0.001],
		"_RimFresnelPower": [0.0, 100.0, 0.01],
		"_Outline_Width": [0.0, 1.0, 0.001],
	}


func defaults() -> Dictionary:
	return {
		"_Color": Color(1, 1, 1, 1),
		"_1st_ShadeColor": Color(0.82, 0.76, 0.85, 1.0),
		"_BaseColor_Step": 0.5,
		"_BaseShade_Feather": 0.1,
		"_RimFresnelPower": 3.0,
		"_BumpScale": 1.0,
		"_Cutoff": 0.5,
	}


func labels() -> Dictionary:
	return {
		"_Color": ["Base Color, Alpha", "Base color (RGB) and alpha (A)."],
		"_MainTex": ["Base Texture", "Base color texture."],
		"_Cutoff": ["Alpha Cutoff", "Discard pixels below this alpha in cutout mode."],
		"_BumpMap": ["Normal Map", "Tangent-space normal map."],
		"_BumpScale": ["Normal Scale", "Normal map strength."],
		"_1st_ShadeColor": ["1st Shade Color", "First shade color (SCSS/UTS2 _1st_ShadeColor)."],
		"_BaseColor_Step": ["Base/Shade Step", "Lit/shade boundary (SCSS _BaseColor_Step)."],
		"_BaseShade_Feather": ["Step Feather", "Softness of the shade boundary (SCSS _BaseShade_Feather)."],
		"_RimColor": ["Rim Color", "Fresnel rim color (RGB); alpha scales strength."],
		"_RimFresnelPower": ["Rim Power", "Higher = sharper rim."],
		"_EmissionColor": ["Emission", "Emission color (RGB)."],
		"_EmissionMap": ["Emission Map", "Emission texture."],
		"_OutlineMode": ["Outline Mode", "Outline width space. None disables the outline (scaffold)."],
		"_Outline_Width": ["Outline Width", "Outline thickness (scaffold)."],
		"_Outline_Color": ["Outline Color", "Outline color (scaffold)."],
	}
