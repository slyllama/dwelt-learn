shader_type canvas_item;

uniform sampler2D holograph: filter_nearest, repeat_enable;

vec4 lighten(vec4 base, vec4 blend) {
	return max(base, blend);
}

void fragment() {
	vec2 holo_uv = UV * 2.0 + TIME * 0.2 * vec2(1.0, 0.5);
	vec4 holo_tex = texture(holograph, holo_uv);
	COLOR.rgb = mix(COLOR.rgb, lighten(COLOR, holo_tex).rgb, 0.07);
}
