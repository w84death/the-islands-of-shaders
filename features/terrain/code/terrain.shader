shader_type spatial;

uniform vec2 map_size = vec2(512.0, 512.0);
uniform float max_height = 18.0;

uniform sampler2D height_map;
uniform sampler2D features_map;
uniform float water_height = 0.6;
uniform sampler2D tex_black: hint_albedo;
uniform sampler2D tex_red : hint_albedo;
uniform sampler2D tex_green : hint_albedo;
uniform sampler2D tex_blue : hint_albedo;

uniform float uv_scale = 32.0;

float get_height(vec2 pos) {
	pos -= .5 * map_size;
	pos /= map_size;
	return max_height * texture(height_map, pos).r;
}

void vertex() {
	VERTEX.y = get_height(VERTEX.xz);
	
	TANGENT = normalize(vec3(1.0, get_height(VERTEX.xz + vec2(2.0, 0.0)) - VERTEX.y, 0.0));
	BINORMAL = normalize(vec3(0.0, get_height(VERTEX.xz + vec2(0.0, 2.0)) - VERTEX.y, 1.0));
	NORMAL = cross(BINORMAL, TANGENT);
}

void fragment() {
	vec2 uv2 = UV;
	uv2 *= vec2(-1.0,-1.0); // mirrored
	
	float uv_0 = clamp(1.0 - texture(features_map, uv2).r - texture(features_map, uv2).g - texture(features_map, uv2).b,0.0,1.0);
	float uv_r = texture(features_map, uv2).r;
	float uv_g = texture(features_map, uv2).g;
	float uv_b = texture(features_map, uv2).b;
	
	vec3 color_0 = texture(tex_black, uv2 * uv_scale).rgb * uv_0;
	vec3 color_r = texture(tex_red, uv2 * uv_scale).rgb * uv_r;
	vec3 color_g = texture(tex_green, uv2 * uv_scale).rgb * uv_g;
	vec3 color_b = texture(tex_blue, uv2 * uv_scale).rgb * uv_b;

	vec3 underwater_color = vec3(1.0);
	float height = texture(height_map, uv2).r;
	if (height < water_height){
		float h = clamp((water_height-height)*6.0, 0.0, 1.0);
		underwater_color.r -= h;
		underwater_color.g -= h*.5;
	}
	
	ALBEDO = clamp((color_0 + color_r + color_g + color_b) * underwater_color, 0.0, 1.0);
	METALLIC = 0.7;
	ROUGHNESS = 1.0;
}
