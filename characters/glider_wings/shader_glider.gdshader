shader_type spatial;
render_mode shadows_disabled;

uniform sampler2D stars_texture;
uniform float stars_scale = 5.0;
uniform sampler2D noise_texture;
uniform vec4 fresnel_color: source_color;
uniform float fresnel_amount = 1.0;
uniform float fresnel_intensity = 1.0;
uniform float alpha_float = 0.5;

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

void fragment()
{
	vec2 adjusted_screen_uv = SCREEN_UV;
	vec2 noise_uv = adjusted_screen_uv + TIME * 0.04;
	vec2 noise_final = vec2(texture(noise_texture, noise_uv).r, texture(noise_texture, noise_uv).g);
	vec3 fresnel = fresnel_glow(fresnel_amount, fresnel_intensity, fresnel_color.rgb, NORMAL, VIEW);
	
	vec4 tex_col = texture(stars_texture, adjusted_screen_uv * stars_scale + noise_final * 0.4);
	ALBEDO = vec3(0, 0, 0);
	ALPHA = alpha_float;
	EMISSION = tex_col.rgb / 4.0 + fresnel;
	SPECULAR = 0.0;
}
