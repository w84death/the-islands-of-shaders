shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec2 map_size = vec2(512.0, 512.0);
uniform float max_height = 18.0;
uniform float water_height = 0.6;

uniform float mountains_level = 0.7;
uniform float mountains_size = 3.0;

uniform sampler2D height_map;
uniform sampler2D features_map;

uniform sampler2D black_albedo : hint_albedo;
uniform sampler2D black_ao : hint_albedo;
uniform sampler2D black_nrm : hint_normal;
uniform sampler2D black_spec;
uniform sampler2D black_rgh;

uniform sampler2D red_albedo : hint_albedo;
uniform sampler2D red_ao : hint_albedo;
uniform sampler2D red_nrm : hint_normal;
uniform sampler2D red_spec;
uniform sampler2D red_rgh;

uniform sampler2D green_albedo : hint_albedo;
uniform sampler2D green_ao : hint_albedo;
uniform sampler2D green_nrm : hint_normal;
uniform sampler2D green_spec;
uniform sampler2D green_rgh;

uniform sampler2D blue_albedo : hint_albedo;
uniform sampler2D blue_ao : hint_albedo;
uniform sampler2D blue_nrm : hint_normal;
uniform sampler2D blue_spec;
uniform sampler2D blue_rgh;

uniform float uv_scale = 32.0;

float get_height(vec2 pos) {
	pos -= .5 * map_size;
	pos /= map_size;
	float h = texture(height_map, pos).r;
	if (h>mountains_level) {
		h += (h-mountains_level)*mountains_size;
	}
	return max_height * h;
}

void vertex() {
	VERTEX.y = get_height(VERTEX.xz);
	float A = 0.3;
	float B = 0.2;
	TANGENT = normalize( vec3(0.0, get_height(VERTEX.xz + vec2(0.0, B)) - get_height(VERTEX.xz + vec2(0.0, -0.1)), A));
	BINORMAL = normalize( vec3(A, get_height(VERTEX.xz + vec2(B, 0.0)) - get_height(VERTEX.xz + vec2(-0.1, 0.0)), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment() {
	vec2 uv2 = UV;
	uv2 *= vec2(-1.0,-1.0); // mirrored
	
	// get zones
	float zone_0 = clamp(1.0 - texture(features_map, uv2).r - texture(features_map, uv2).g - texture(features_map, uv2).b,0.0,1.0);
	float zone_r = texture(features_map, uv2).r;
	float zone_g = texture(features_map, uv2).g;
	float zone_b = texture(features_map, uv2).b;
	
	vec3 albedo_0 = texture(black_albedo, uv2 * uv_scale).rgb * zone_0;
	vec3 albedo_r = texture(red_albedo, uv2 * uv_scale).rgb * zone_r;
	vec3 albedo_g = texture(green_albedo, uv2 * uv_scale).rgb * zone_g;
	vec3 albedo_b = texture(blue_albedo, uv2 * uv_scale).rgb * zone_b;

	vec3 nrm_0 = texture(black_nrm, uv2 * uv_scale).rgb * zone_0;
	vec3 nrm_r = texture(red_nrm, uv2 * uv_scale).rgb * zone_r;
	vec3 nrm_g = texture(green_nrm, uv2 * uv_scale).rgb * zone_g;
	vec3 nrm_b = texture(blue_nrm, uv2 * uv_scale).rgb * zone_b;
	
	vec3 rgh_0 = texture(black_rgh, uv2 * uv_scale).rgb * zone_0;
	vec3 rgh_r = texture(red_rgh, uv2 * uv_scale).rgb * zone_r;
	vec3 rgh_g = texture(green_rgh, uv2 * uv_scale).rgb * zone_g;
	vec3 rgh_b = texture(blue_rgh, uv2 * uv_scale).rgb * zone_b;

	vec3 spec_0 = texture(black_spec, uv2 * uv_scale).rgb * zone_0;
	vec3 spec_r = texture(red_spec, uv2 * uv_scale).rgb * zone_r;
	vec3 spec_g = texture(green_spec, uv2 * uv_scale).rgb * zone_g;
	vec3 spec_b = texture(blue_spec, uv2 * uv_scale).rgb * zone_b;
	
	vec3 underwater_color = vec3(1.0);
	float height = texture(height_map, uv2).r;
	if (height < water_height){
		float h = clamp((water_height-height)*6.0, 0.0, 1.0);
		underwater_color.r -= h;
		underwater_color.g -= h*.5;
	}
	
	ALBEDO = clamp((albedo_0 + albedo_r + albedo_g + albedo_b) * underwater_color, 0.0, 1.0);
	METALLIC = 0.75;
	SPECULAR = spec_0.r + spec_r.r + spec_g.r + spec_b.r;
	ROUGHNESS = rgh_0.r + rgh_r.r + rgh_g.r + rgh_b.r;
	NORMALMAP = nrm_0 + nrm_r + nrm_g + nrm_b;
	NORMALMAP_DEPTH = -5.0;
}
