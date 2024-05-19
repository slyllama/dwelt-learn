shader_type canvas_item;

uniform sampler2D noise: repeat_enable, filter_linear_mipmap;
uniform float alpha_scale = 1.0;

void fragment() {
	vec3 noise_mask = texture(noise, UV + vec2(0.1 * TIME, 0.0)).rgb;
	vec2 noise_uv = UV + noise_mask.rg * 0.01;
	COLOR = texture(TEXTURE, noise_uv);
	COLOR.a = COLOR.a * alpha_scale;
}
