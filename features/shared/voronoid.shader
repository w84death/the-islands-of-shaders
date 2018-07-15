shader_type spatial;
/* VORONOID PATTERN V1.0 */

uniform float UNIQ = 4323.1454;
uniform float MAX_ITER = 128.0;
uniform float SPEED = 0.2;

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}
vec2 faker(vec2 p){
	return vec2(fake_random(p),fake_random(p*UNIQ));
}

float voronoi (vec2 uv, float t) {
	float md = 100.0;
	float id = 0.0;
	
	for (float i=0.0; i<MAX_ITER; i++){
		vec2 n = faker(vec2(i));
		vec2 p = sin(n*t*SPEED);
		
		float d = length(uv.xy-p);
		if (d<md) {
			md = d;
			id = i;
		}
	}
	
	return md;
}

void fragment() {
	float c = voronoi(UV, TIME);
	
	float r = clamp(c*.5, 0.0,1.0);
	float g = clamp(c*1.2, 0.0,1.0);
	float b = clamp(c*1.4, 0.0,1.0);
	ALBEDO = vec3(r, g, b) * 2.5;
	ALPHA = clamp(c*5.0, 0.2, 1.0);
	METALLIC = .6;
	SPECULAR = 0.0;
	ROUGHNESS = 0.5;
}