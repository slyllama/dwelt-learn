shader_type spatial;
render_mode shadows_disabled;

uniform sampler2D holo_texture: filter_linear_mipmap, repeat_enable;
uniform vec4 fresnel_color: source_color;
uniform float alpha_float = 1.0;
uniform float overall_scale = 6.0;
uniform float exponent = 1.0;

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

void fragment()
{
	vec2 adjusted_screen_uv = SCREEN_UV;
	vec3 fresnel = fresnel_glow(1.0, 0.2, fresnel_color.rgb, NORMAL, VIEW);
	
	ALBEDO = fresnel * 4.0;
	//ALPHA = alpha_float;
	ALPHA = pow(texture(holo_texture, SCREEN_UV * overall_scale + vec2(0.0, TIME * 0.2)).r, exponent) * alpha_float;
	EMISSION = fresnel;
	SPECULAR = 0.0;
}
