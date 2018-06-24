shader_type spatial;

uniform sampler2D tex;
uniform sampler2D noise_map;
uniform float uv_scale = 2.0;

void vertex(){
	float n = texture(noise_map, VERTEX.xz).r;
	VERTEX.y *= clamp(n, 0.0, 20.0);
}
void fragment(){
	vec3 color = texture(tex, UV.xy * uv_scale).rgb;
	ALBEDO = color;
	METALLIC = 0.8;
	ROUGHNESS = 1.0;
}