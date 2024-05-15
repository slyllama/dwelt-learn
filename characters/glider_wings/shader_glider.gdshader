shader_type spatial;
render_mode shadows_disabled;

uniform vec4 fresnel_color: source_color;
uniform float fresnel_amount = 1.0;
uniform float fresnel_intensity = 1.0;
uniform float alpha_float = 1.0;

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

void fragment()
{
	vec2 adjusted_screen_uv = SCREEN_UV;
	vec3 fresnel = fresnel_glow(fresnel_amount, fresnel_intensity, fresnel_color.rgb, NORMAL, VIEW);
	
	ALBEDO = fresnel * 4.0;
	ALPHA = alpha_float;
	EMISSION = fresnel;
	SPECULAR = 0.0;
}
