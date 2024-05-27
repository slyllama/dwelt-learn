shader_type canvas_item;

uniform vec2 size = vec2(10.0, 10.0);
uniform sampler2D gradient: filter_linear_mipmap, repeat_enable;

varying vec2 full_uv;

void vertex () { full_uv = VERTEX.xy / size; }

void fragment() {
	COLOR.a = COLOR.a * texture(gradient, full_uv).r * 0.8;
}

