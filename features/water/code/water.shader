shader_type spatial;
render_mode vertex_lighting;
render_mode blend_add;

uniform float uv_scale = 64.0;
uniform float flow_speed = 0.003;

uniform sampler2D height_map;
uniform sampler2D flow_map;
uniform sampler2D noise_map;
uniform sampler2D normal_map;

void vertex() {
	vec3 noise = texture(noise_map, VERTEX.xz * 0.1).rgb;
	VERTEX.y += noise.x * 4.0 * (sin(VERTEX.x + VERTEX.y + TIME) * 0.4);
}

void fragment() {
	// revert uv
	vec2 uv2 = UV;
	uv2 *= vec2(-1.0,-1.0);
	
	// get pixel color
	float land_line = texture(height_map, uv2.xy).r;
	vec2 flow = texture(flow_map, uv2.xy).rg * 2.0 - 1.0;
	
	// calc water color/alpha on land height
	float line_color = clamp(land_line * 4.0, 0.0, 1.0);
	vec3 new_color = vec3(0.1, .6-line_color, .5-line_color) - vec3(0.15, 0.4, 0.4);
	ALBEDO = clamp(new_color, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0));
	ALPHA = 1.0 - line_color * 2.0;
	ROUGHNESS = clamp(line_color, 0.27, 1.0);
	METALLIC = 0.35;

	// animate normals with flow
	float lerp_time = (abs(0.5 - TIME) / 0.5) * flow_speed;
	vec2 flow_normal = uv2.xy * (flow) + lerp_time;
	NORMALMAP = texture(normal_map, flow_normal * uv_scale).rgb;
}
