shader_type spatial;
render_mode vertex_lighting;

uniform float uv_scale = 32.0;
uniform float flow_speed = 0.02;
uniform float time_shift = 0.005;

uniform sampler2D height_map;
uniform sampler2D flow_map;
uniform sampler2D noise_map;
uniform sampler2D normal_map;

void vertex() {
	vec3 noise = texture(noise_map, VERTEX.xz * 0.1).rgb;
	VERTEX.y -= noise.x * 2.5 * (sin(VERTEX.x + VERTEX.y + TIME) * 0.4);
}

void fragment() {
	ALBEDO = vec3(0.06, 0.48, 0.51);
	ALPHA = 0.75;
	ROUGHNESS = 0.35;
	
	vec2 uv2 = UV;
	uv2 *= vec2(-1.0,-1.0);
	vec2 flow = texture(flow_map, uv2.xy).gr * 2.0 - 1.0;
	float lerp_time = (abs(0.5 - TIME) / 0.5) * time_shift;
	vec2 flow_normal = uv2.yx * flow + lerp_time;
	NORMALMAP = texture(normal_map, flow_normal * uv_scale).rgb;
}

