shader_type spatial;

uniform sampler2D stars_texture;
uniform float stars_scale = 5.0;
uniform sampler2D noise_texture;

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

void fragment()
{
	vec2 adjusted_screen_uv = SCREEN_UV * 0.5;
	
	vec2 noise_uv = adjusted_screen_uv + TIME * 0.04;
	vec2 noise_final = vec2(texture(noise_texture, noise_uv).r, texture(noise_texture, noise_uv).g);
	vec3 fresnel_color = vec3(0.0, 0.7, 0.9);
	vec3 fresnel = fresnel_glow(7.0, 5.0, fresnel_color, NORMAL, VIEW);
	
	vec4 tex_col = texture(stars_texture, adjusted_screen_uv * stars_scale + noise_final * 0.9);
	ALBEDO = vec3(0, 0, 0);
	EMISSION = tex_col.rgb / 4.0 + fresnel;
	SPECULAR = 0.0;
}
