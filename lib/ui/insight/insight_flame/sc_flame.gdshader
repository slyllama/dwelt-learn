shader_type canvas_item;

uniform sampler2D alpha_channel: repeat_enable, filter_linear_mipmap;
uniform sampler2D noise: repeat_enable, filter_linear_mipmap;
uniform sampler2D influence_gradient: filter_linear_mipmap;
uniform float exponent = 10.0;
uniform float alpha_scale = 1.0;

void fragment() {
	vec3 noise_mask = texture(noise, UV + vec2(0.1 * TIME, 0.0)).rgb;
	vec2 noise_uv = UV + noise_mask.rg * 0.2 * texture(influence_gradient, UV).r;
	COLOR.a = texture(alpha_channel, noise_uv).r * (1.0 - texture(influence_gradient, UV).r) - pow(noise_mask.r, exponent);
	COLOR.a = COLOR.a * alpha_scale;
}
