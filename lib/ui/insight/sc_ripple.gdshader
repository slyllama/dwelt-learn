shader_type canvas_item;

uniform sampler2D noise: repeat_enable, filter_linear_mipmap;
uniform vec4 base_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha_scale = 1.0;
uniform float intensity = 0.01;

vec4 multiply(vec4 base, vec4 blend) { return base * blend; }

void fragment() {
	vec3 noise_mask = texture(noise, UV + vec2(0.1 * TIME, 0.0)).rgb;
	vec2 noise_uv = UV + noise_mask.rg * intensity - UV * intensity;
	COLOR = texture(TEXTURE, noise_uv);
	COLOR.a = COLOR.a * alpha_scale;
	COLOR = multiply(COLOR, base_color);
}
