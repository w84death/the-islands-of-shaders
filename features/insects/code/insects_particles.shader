shader_type particles;

uniform float rows = 32;
uniform float spacing = 1.0;
uniform float flapping_speed = 28.0;
uniform float fly_range = 24.0;
uniform float max_height = 64.0;

uniform sampler2D height_map;

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}
vec2 faker(vec2 p){
	return vec2(fake_random(p),fake_random(p*434.23));
}

void vertex() {
	// obtain our position based on which particle we're rendering
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, rows);
	pos.z = (pos.z - pos.x) / rows;
	
	// center this
	pos.x -= rows * 0.5;
	pos.z -= rows * 0.5;
	
	// and now apply our spacing
	pos *= spacing;
	
	// now center on our particle location but within our spacing
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], spacing);
	
	vec2 noise = faker(pos.xz * 0.02);
	float height = texture(height_map, pos.xz).r;
	
	pos.x += (noise.x * 4.0 ) * spacing;
	pos.z += (noise.y * 4.0 ) * spacing;
	pos.y = (height + (max_height-height) * noise.y);
	
	
	TRANSFORM[1][1] = 1.5 + sin(TIME * flapping_speed + pos.x);
	
	TRANSFORM[3][0] = pos.x + sin(TIME + noise.x + pos.x) * fly_range;
	TRANSFORM[3][1] = (height * max_height)  + pos.y + sin(TIME - noise.x + pos.y) * (fly_range * 0.25);
	TRANSFORM[3][2] = pos.z + sin(TIME + noise.y + pos.z) * fly_range;
}