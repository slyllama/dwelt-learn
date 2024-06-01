shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 base_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D smoke_texture: repeat_enable, filter_linear_mipmap;
uniform float alpha_scale = 0.5;

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view) {
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity; }

void fragment() {
	float spicy = pow(texture(smoke_texture, UV + TIME * 0.03).r * 0.03, 1.1);
	vec3 c = textureLod(screen_texture, SCREEN_UV / 1.02 + spicy, 0.0).rgb;
	
	ALBEDO = c.rgb + fresnel_glow(2.0, 0.1, base_color.rgb, NORMAL, VIEW);
	ALBEDO += spicy;
	ALPHA = alpha_scale;
}
