shader_type spatial;
// spatial = 3d shader

uniform float level : hint_range(0.0, 1.0) = 1.0;
uniform float emission_intensity : hint_range(0.0, 1.0);

group_uniforms fresnel;
uniform vec3 fresnel_color: source_color;
uniform float fresnel_intensity: hint_range(1.0, 10.0) = 1.0;
uniform float fresnel_power: hint_range(0.0, 10.0) = 1.0;


void fragment() {
	float dir = 1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel_amount = pow(dir, fresnel_power) * fresnel_intensity;
	vec3 fresnel = fresnel_color * fresnel_amount;

	ALBEDO = fresnel;
	EMISSION = fresnel * emission_intensity * level;
	ALPHA = fresnel_amount * level;
}
