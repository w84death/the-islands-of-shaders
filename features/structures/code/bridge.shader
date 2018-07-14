shader_type spatial;

uniform sampler2D tex : hint_albedo;
uniform float uv_scale = 4.0;

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 faker(vec2 p){
	return vec2(fake_random(p), fake_random(p*124.32));
}

void vertex(){
	float n = fake_random(VERTEX.xz)*10.0;
	VERTEX.y += -5.0 + clamp(n, 0.0, 10.0);
}

void fragment(){
	vec3 color = texture(tex, UV.xy*uv_scale).rgb;
	ALBEDO = color;
	METALLIC = 0.8;
	ROUGHNESS = 1.0;
}