// terrain shader
// kj/P1X http://p1x.in
// code taken from:
// -
// -
//

shader_type spatial;

uniform vec2 map_size = vec2(512.0, 512.0);
uniform float max_height = 18.0;

uniform sampler2D height_map;
uniform sampler2D features_map;

uniform sampler2D albedo_red : hint_albedo;
uniform sampler2D albedo_green : hint_albedo;
uniform sampler2D albedo_blue : hint_albedo;
uniform sampler2D normalmap_red : hint_normal;
uniform sampler2D normalmap_green : hint_normal;
uniform sampler2D normalmap_blue : hint_normal;

uniform float uv_scale = 32.0;

float get_height(vec2 pos) {
	pos -= .5 * map_size;
	pos /= map_size;
	return max_height * texture(height_map, pos).r;
}

void vertex() {
	VERTEX.y = get_height(VERTEX.xz);
	//VERTEX = vec3(VERTEX.x, texture(height_map, UV).r * float(max_height), VERTEX.z);
	
	TANGENT = normalize(vec3(1.0, get_height(VERTEX.xz + vec2(1.0, 0.0)) - VERTEX.y, 0.0));
	BINORMAL = normalize(vec3(0.0, get_height(VERTEX.xz + vec2(0.0, 1.0)) - VERTEX.y, 1.0));
	NORMAL = cross(BINORMAL, TANGENT);
}

void fragment() {
	vec2 uv2 = UV;
	uv2 *= vec2(-1.0,-1.0); // mirrored
	
	float red_vis = texture(features_map, uv2).r;
	float green_vis = texture(features_map, uv2).g;
	float blue_vis = texture(features_map, uv2).b;
	
	vec3 red_color = texture(albedo_red, uv2 * uv_scale).rgb * red_vis;
	vec3 green_color = texture(albedo_green, uv2 * uv_scale).rgb * green_vis;
	vec3 blue_color = texture(albedo_blue, uv2 * uv_scale).rgb * blue_vis;
	
	vec3 red_normal = texture(normalmap_red, uv2).rgb * red_vis;
	vec3 green_normal = texture(normalmap_green, uv2).rgb * green_vis;
	vec3 blue_normal = texture(normalmap_blue, uv2).rgb * blue_vis;
	
	ALBEDO = red_color + green_color + blue_color;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	//NORMALMAP = red_normal + green_normal + blue_normal;
}