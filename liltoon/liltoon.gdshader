shader_type spatial;
render_mode cull_back;
// lilToon (Godot port) — initial core-parameter shader. Uniform names follow
// lilToon's Unity property names (see ../PARAMETERS.md) so material parameters
// port across MToon / SCSS / lilToon. A simple toon ramp + rim + emission today;
// outline pass and lilToon's full feature set are TODO.

uniform vec4 _Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D _MainTex : source_color, hint_default_white;
uniform float _Cutoff : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D _BumpMap : hint_normal;
uniform float _BumpScale = 1.0;

uniform vec4 _ShadowColor : source_color = vec4(0.82, 0.76, 0.85, 1.0);
uniform float _ShadowBorder : hint_range(0.0, 1.0) = 0.5;
uniform float _ShadowBlur : hint_range(0.0, 1.0) = 0.1;

uniform vec4 _RimColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float _RimFresnelPower : hint_range(0.0, 100.0) = 3.0;

uniform vec4 _EmissionColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D _EmissionMap : source_color, hint_default_black;

// Outline scaffold (full outline pass TODO) + matcap reference.
uniform int _OutlineWidthMode = 0;       // 0 None, 1 World, 2 Screen
uniform float _OutlineWidth : hint_range(0.0, 1.0) = 0.0;
uniform vec4 _OutlineColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D _MatCapTex : hint_default_black;

void fragment() {
	vec4 base = texture(_MainTex, UV) * _Color;
	ALBEDO = base.rgb;
	ALPHA = base.a;
	NORMAL_MAP = texture(_BumpMap, UV).rgb;
	NORMAL_MAP_DEPTH = _BumpScale;
	EMISSION = (_EmissionColor * texture(_EmissionMap, UV)).rgb;
}

void light() {
	// Toon ramp: blurred step at the shade border between lit and shade color.
	float ndl = dot(NORMAL, LIGHT) * 0.5 + 0.5;
	float ramp = smoothstep(_ShadowBorder - _ShadowBlur, _ShadowBorder + _ShadowBlur, ndl);
	vec3 lit = ALBEDO * LIGHT_COLOR * ATTENUATION;
	vec3 shade = ALBEDO * _ShadowColor.rgb * LIGHT_COLOR;
	DIFFUSE_LIGHT += mix(shade, lit, ramp);
	// Fresnel rim, additive.
	float fres = pow(1.0 - max(dot(NORMAL, VIEW), 0.0), max(_RimFresnelPower, 0.001));
	DIFFUSE_LIGHT += _RimColor.rgb * fres * _RimColor.a;
}
