shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D radar: repeat_enable, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5) = 1.0;
uniform float state = 0.0;

float circle(vec2 position, float radius, float feather) {
	return smoothstep(
		radius, radius + feather, length(position - vec2(0.5)));
}

void fragment(){
	float mask = circle(SCREEN_UV, 0.15, 0.2);
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod * state * (1.0 - mask));
	color.rgb = color.rgb * clamp(mask, 0.7 + 0.3 * (1.0 - state), 1.0);
	COLOR = color;
	COLOR.a = COLOR.a * pow(
		texture(radar, SCREEN_UV * 10.0 + vec2(0.0, TIME * 0.1)).r, 0.5);
}
