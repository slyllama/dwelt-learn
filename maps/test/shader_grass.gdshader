shader_type spatial;

uniform sampler2D grass_texture;
uniform sampler2D light_mask;
uniform sampler2D normal_map;
uniform sampler2D detailed_normal_map;
uniform float scale = 32.0;

vec3 normal_blend(vec3 base, vec3 detail) {
	return(vec3(base.xy + detail.xy - 0.5, 1.0));
}

void fragment() {
	//ALBEDO.rbg = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), texture(light_mask, UV).r);
	float light = texture(light_mask, UV).r;
	vec3 diffuse = texture(grass_texture, UV * scale).rgb;
	
	vec3 d1 = diffuse * 0.005;
	vec3 d2 = diffuse * 0.2;

	ALBEDO.rgb = mix(d1, d2, light);
	SPECULAR = 0.0;
	
	vec3 norm_base = texture(normal_map, UV).rgb;
	vec3 norm_detail = texture(detailed_normal_map, UV * scale).rgb;
	
	NORMAL_MAP = normal_blend(norm_base, norm_detail);
	NORMAL_MAP_DEPTH = 2.0;
}
