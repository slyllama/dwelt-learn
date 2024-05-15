shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform vec2 center;
uniform float force;
uniform float size;
uniform float thickness;

void fragment() {
	// Multiply by 1.5 for an isometric distortion
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y * 1.5;
	vec2 scaledUV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	float mask = (1.0 - smoothstep(size - 0.1, size - thickness, length(scaledUV - center))) *
		smoothstep(size - 0.2, size - 0.1, length(scaledUV - center));
	vec2 disp = normalize(scaledUV - center) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}
