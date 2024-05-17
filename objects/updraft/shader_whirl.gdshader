shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 base_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D whirl_texture: repeat_enable;
uniform sampler2D alpha_mask;
uniform sampler2D x_alpha_mask;
uniform sampler2D distortion;

void fragment() {
	vec2 uv = UV - vec2(TIME * 0.55, 1.0);
	
	vec2 distortion_value = texture(distortion, UV).rg;
	float whirl_value = texture(whirl_texture, uv + distortion_value * 0.3).r;
	
	float alpha_mask_value = texture(alpha_mask, UV).r;
	float x_alpha_mask_value = texture(x_alpha_mask, UV).r;
	
	ALPHA = pow(whirl_value, 2.3) * alpha_mask_value * x_alpha_mask_value;
	ALBEDO = vec3(base_color.rgb);
}
