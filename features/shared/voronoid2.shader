shader_type spatial;
/* VORONOID PATTERN V2.0 */

uniform float UNIQ = 4323.1454;
uniform float SPEED = 0.2;
uniform float SIZE = 4.0;

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}
vec2 faker(vec2 p){
	return vec2(fake_random(p),fake_random(p*UNIQ));
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

void fragment() {
	float c = voronoi(UV*SIZE, TIME);
	
	float r = clamp(c*0.5, 0.0,1.0);
	float g = clamp(c*2.2, 0.0,1.0);
	float b = clamp(c*1.4, 0.0,1.0);
	ALBEDO = vec3(r, g, b);
	ALPHA = c;
	METALLIC = .6;
	SPECULAR = 0.0;
	ROUGHNESS = 0.5;
}