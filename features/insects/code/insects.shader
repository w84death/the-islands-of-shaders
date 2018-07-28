shader_type spatial;
//render_mode cull_disabled;

uniform sampler2D texture_map : hint_albedo;
uniform sampler2D normal_map : hint_normal;
uniform sampler2D specular_map : hint_black;

uniform float amplitude = 0.2;
uniform vec2 speed = vec2(2.0, 1.5);
uniform vec2 scale = vec2(0.1, 0.2);

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 faker(vec2 p){
	return vec2(fake_random(p), fake_random(p*124.32));
}

void vertex() {
	vec3 worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.x += amplitude * sin(worldpos.x * scale.x * 0.75 + TIME * speed.x) * cos(worldpos.z * scale.x + TIME * speed.x * 0.25);
	VERTEX.z += amplitude * sin(worldpos.x * scale.y + TIME * speed.y * 0.35) * cos(worldpos.z * scale.y * 0.80 + TIME * speed.y);
	
	vec4 color = vec4(fake_random(VERTEX.xz), fake_random(VERTEX.xz), fake_random(VERTEX.xz), 1.0);
	VERTEX.x += color.x * 1.0;
	VERTEX.z += color.y * 0.4;
	VERTEX.y += color.x * 0.7;
}

void fragment() {
	vec4 color = texture(texture_map, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a;
	ALPHA_SCISSOR = 0.10;
	
	METALLIC = 0.80;
	SPECULAR = texture(specular_map, UV).r;
	ROUGHNESS = clamp(1.0-SPECULAR, 0.2, 1.0);
	TRANSMISSION = vec3(0.2, 0.2, 0.2);
}