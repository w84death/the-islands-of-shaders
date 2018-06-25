shader_type spatial;
/* WATER SHADER 3.0 "Back to the roots" */

uniform vec2 amplitude = vec2(1.0, 1.0);
uniform vec2 frequency = vec2(.2, .2);
uniform vec2 time_factor = vec2(2.0, 2.0);

uniform vec3 water_color = vec3(0.25, 0.27, 0.15);
uniform float water_height = 2.5;
uniform float water_clearnes = 0.4;
uniform float water_refraction = 0.014;
uniform float water_alpha = 0.7;
uniform float water_shore = 0.36;
uniform float water_color_contrast = 6.0;

uniform sampler2D height_map;

float height(vec2 pos, float time, float noise){
	return (amplitude.x * sin(pos.x * frequency.x * noise + time * time_factor.x)) + (amplitude.y * sin(pos.y * frequency.y * noise + time * time_factor.y));
}

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 faker(vec2 p){
	return vec2(fake_random(p), fake_random(p*124.32));
}
	
void vertex(){
	float noise = faker(VERTEX.xz).x;
	VERTEX.y = water_height + height(VERTEX.xz, TIME, noise);
	TANGENT = normalize( vec3(0.0, height(VERTEX.xz + vec2(0.0, 0.2), TIME, noise) - height(VERTEX.xz + vec2(0.0, -0.2), TIME, noise), 0.4));
	BINORMAL = normalize( vec3(0.4, height(VERTEX.xz + vec2(0.2, 0.0), TIME, noise) - height(VERTEX.xz + vec2(-0.2, 0.0), TIME, noise), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment(){
	vec2 uv2 = UV * -1.0;
	float height = texture(height_map, uv2.xy).r;
	
	float gfx = smoothstep(0.15, water_shore, height);
	ALPHA = 1.0 - clamp(gfx, water_alpha, 1.0);
	vec3 w_color = vec3(gfx, gfx, gfx) * water_color_contrast;
	
	ALBEDO = w_color;
	ROUGHNESS = gfx;
	METALLIC = 0.8;
	SPECULAR = gfx;
	
	// REFRACTION
	vec3 ref_normal = normalize( mix(VERTEX,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + VERTEX * NORMALMAP.z, NORMALMAP_DEPTH) );
	vec2 ref_ofs = SCREEN_UV + ref_normal.xy * water_refraction;
	EMISSION += textureLod(SCREEN_TEXTURE, ref_ofs, ROUGHNESS * water_clearnes).rgb * (1.0 - ALPHA);
	ALBEDO *= ALPHA;
	ALPHA = 1.0;
}