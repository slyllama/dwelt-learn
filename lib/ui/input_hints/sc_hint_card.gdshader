shader_type canvas_item;

uniform sampler2D gradient_texture: filter_linear_mipmap;
uniform float alpha_scale = 1.0;
uniform float base_color = 1.0;

void fragment() {
	COLOR.rgb = vec3(base_color);
	COLOR.a = texture(gradient_texture, UV).r * alpha_scale;
}
