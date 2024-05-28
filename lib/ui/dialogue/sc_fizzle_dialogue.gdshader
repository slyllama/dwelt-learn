shader_type canvas_item;

uniform sampler2D radar_texture: repeat_enable, filter_linear_mipmap;
uniform float exponent = 0.01;
uniform float alpha_scale = 1.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	float alpha_mask = texture(radar_texture, UV * 3.5).r;
	COLOR.a = COLOR.a * pow(alpha_mask, exponent) * alpha_scale;
}
