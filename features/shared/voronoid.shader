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
	
	ALBEDO = vec3(c*4.0, 1.0-c*.5, 1.0);
	ALPHA = c*5.0;
	METALLIC = .9;
	SPECULAR = 1.0;
	ROUGHNESS = .0;
}