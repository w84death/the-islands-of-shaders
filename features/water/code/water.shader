shader_type spatial;
/* WATER SHADER 3.0 "Back to the roots" */

uniform vec2 amplitude = vec2(1.0, 1.0);
uniform vec2 frequency = vec2(1.1, 1.1);
uniform vec2 time_factor = vec2(2.0, 2.0);

uniform vec3 water_color = vec3(0.25, 0.27, 0.15);
uniform float water_height = 2.5;
uniform float water_clearnes = 0.6;
uniform float water_refraction = 0.01;
uniform float water_alpha = 0.7;

uniform sampler2D noise_map;
uniform sampler2D height_map;

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
	vec2 uv2 = UV * -1.0;
	float height = texture(height_map, uv2.xy).r;
	
	float gfx = clamp(height * 3.0, 0.0, 1.0);
	ALPHA = clamp(water_alpha * gfx, 0.0, 1.0);
	vec3 w_color = clamp(vec3(gfx, gfx, gfx)*4.0, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
	ALBEDO = w_color;
	
	ROUGHNESS = gfx;
	METALLIC = 1.0;
	//SPECULAR = 1.0;
	
	// REFRACTION
	vec3 ref_normal = normalize( mix(VERTEX,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + VERTEX * NORMALMAP.z, NORMALMAP_DEPTH) );
	vec2 ref_ofs = SCREEN_UV + ref_normal.xy * water_refraction;
	EMISSION += textureLod(SCREEN_TEXTURE, ref_ofs, ROUGHNESS * water_clearnes).rgb * (1.0 - ALPHA);
	ALBEDO *= ALPHA;
	ALPHA = 1.0;
}