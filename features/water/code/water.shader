shader_type spatial;
render_mode vertex_lighting;
render_mode blend_add;

uniform float uv_scale = 64.0;
uniform float flow_speed = 0.003;
uniform float water_height = 2.5;
uniform float shore_height_start = 0.3;
uniform float shore_height_end = 0.08;
uniform float water_alpha = 1.0;
uniform float waves_movement = 0.5;
uniform float waves_speed = 2.0;

uniform sampler2D height_map;
uniform sampler2D flow_map;
uniform sampler2D noise_map;
uniform sampler2D normal_map;

void vertex() {
	vec3 noise = texture(noise_map, VERTEX.xz * 0.1).rgb;
	float sinus = (sin(VERTEX.x + VERTEX.z + (TIME * waves_speed)) * waves_movement);
	VERTEX.y += water_height + noise.x * sinus;
}

void fragment() {
	// revert uv
	vec2 uv2 = UV;
	uv2 *= vec2(-1.0,-1.0);
	
	// calc water color/alpha on land height
	float land_height = texture(height_map, uv2.xy).r;
	vec3 w_color = vec3(0.09, 0.12, 0.2);
	float mul = (abs(land_height)-shore_height_start) / (shore_height_end - shore_height_start);
	
	w_color.r += clamp(1.1 - mul, 0.0, 1.0 - w_color.r);
	w_color.g += clamp(1.14 - mul, 0.0, 1.0 - w_color.g);
	w_color.b += clamp(1.1- mul, 0.0, 1.0 - w_color.b);
	/*
	
	w_color.r -= clamp(mul, w_color.r, 1.0);
	w_color.g -= clamp(mul, w_color.g, 1.0);
	w_color.b -= clamp(mul, w_color.b, 1.0);
	*/
	ALBEDO = w_color;
	float mul2 = (abs(land_height)-shore_height_start) / (0.0 - shore_height_start);
	ALPHA = clamp(mul2, 0.0, water_alpha);
	ROUGHNESS = 0.5;
	METALLIC = 1.0;
	
	// animate normals with flow
	vec2 flow = texture(flow_map, uv2.xy).rg * 2.0 - 1.0;
	float lerp_time = (abs(0.5 - TIME) / 0.5) * flow_speed;
	vec2 flow_normal = uv2.xy * (flow) + lerp_time;
	NORMALMAP = texture(normal_map, flow_normal * uv_scale).rgb;
}
