shader_type spatial;
/* WATER SHADER 3.0 "Back to the roots" */

uniform vec2 amplitude = vec2(1.8, 1.5);
uniform vec2 frequency = vec2(1.4, 1.4);
uniform vec2 time_factor = vec2(2.0, 1.0);

uniform vec3 water_color = vec3(0.01, 0.04, 0.08);
uniform float water_height = 2.5;
uniform float water_clearnes = 0.2;
uniform float water_refraction = 0.015;
uniform float water_alpha = 0.4;

uniform sampler2D noise_map;

float height(vec2 pos, float time, float noise){
	return (amplitude.x * sin(pos.x * frequency.x * noise + time * time_factor.x)) + (amplitude.y * sin(pos.y * frequency.y * noise + time * time_factor.y));
}

void vertex(){
	float noise = texture(noise_map, VERTEX.xz).r * 0.06;
	VERTEX.y = water_height + height(VERTEX.xz, TIME, noise);
	TANGENT = normalize( vec3(0.0, height(VERTEX.xz + vec2(0.0, 0.2), TIME, noise) - height(VERTEX.xz + vec2(0.0, -0.2), TIME, noise), 0.4));
	BINORMAL = normalize( vec3(0.4, height(VERTEX.xz + vec2(0.2, 0.0), TIME, noise) - height(VERTEX.xz + vec2(-0.2, 0.0), TIME, noise), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment(){
	ALBEDO = water_color;
	ROUGHNESS = 0.45;
	METALLIC = 1.0;
	ALPHA = water_alpha;
	
	// REFRACTION
	vec3 ref_normal = normalize( mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH) );
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * water_refraction;
	EMISSION += textureLod(SCREEN_TEXTURE,ref_ofs,ROUGHNESS * water_clearnes).rgb * (1.0 - ALPHA);
	ALBEDO *= ALPHA;
	ALPHA = 1.0;
}