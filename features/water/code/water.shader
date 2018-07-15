shader_type spatial;
/* WATER SHADER 3.0 "Back to the roots" */

uniform vec2 amplitude = vec2(0.5, 0.3);
uniform vec2 frequency = vec2(.2, .2);
uniform vec2 time_factor = vec2(2.0, 2.0);
uniform bool waves_by_height = false;
uniform bool voronoid_effect = false;
uniform float water_height = 2.5;
uniform float water_clearnes = 0.4;
uniform float water_refraction = 0.014;
uniform float water_alpha = 0.2;
uniform float water_shore = 0.37;
uniform float water_color_contrast = 6.0;
uniform float MAX_ITER = 512.0;
uniform float SPEED = 0.1;

uniform sampler2D height_map;

float height(vec2 pos, float time, float noise){
	float t_height = texture(height_map, pos.xy * vec2(1.0)).r;
	float th = 1.0;
	if (waves_by_height) {
		th = t_height*.2;
	}
	return (amplitude.x * th * sin(pos.x * frequency.x * noise + time * time_factor.x)) + (amplitude.y * th * sin(pos.y * frequency.y * noise + time * time_factor.y));
}

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 faker(vec2 p){
	return vec2(fake_random(p), fake_random(p*124.32));
}

float voronoi (vec2 uv, float t) {
	float md = 100.0;
	vec2 gv = fract(uv) - .5;
	vec2 id = floor(uv);
	
	for (float y=-1.0; y<=1.0; y++){
		for (float x=-1.0; x<=1.0; x++){
			vec2 offs = vec2(x, y);
			vec2 n = faker(id+offs);
			vec2 p = offs+sin(n*t*SPEED) * .5;
			
			float d = length(gv-p);
			if (d<md) {
				md = d;
			}
		}
	}
	return md;
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
	float gfx = smoothstep(0.1, water_shore, height);
	vec3 w_color = vec3(gfx, gfx, gfx) * water_color_contrast;
	if (voronoid_effect) { w_color += voronoi(UV*256.0, TIME) * .25; }

	
	ROUGHNESS = 0.3 * gfx;
	METALLIC = 0.8;
	SPECULAR = 1.0 - gfx;
	ALPHA = water_alpha;
	
	ALBEDO = clamp(w_color, .0, 1.0);
	
	// REFRACTION
	vec3 ref_normal = normalize( mix(VERTEX,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + VERTEX * NORMALMAP.z, NORMALMAP_DEPTH) );
	vec2 ref_ofs = SCREEN_UV + ref_normal.xy * water_refraction;
	EMISSION += textureLod(SCREEN_TEXTURE, ref_ofs, ROUGHNESS * water_clearnes).rgb * (1.0 - ALPHA);
	ALBEDO *= ALPHA;
	ALPHA = 1.0;
	
}