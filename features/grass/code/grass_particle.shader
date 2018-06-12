shader_type particles;

uniform float rows = 12;
uniform float spacing = 1.0;
uniform float trees_level = 4;

uniform sampler2D height_map;
uniform sampler2D features_map;
uniform float max_height = 18.0;
uniform vec2 heightmap_size = vec2(512.0, 512.0);

uniform sampler2D noisemap;

float get_height(vec2 pos) {
	pos -= 0.5 * heightmap_size;
	pos /= heightmap_size;
	
	return max_height * texture(height_map, pos).r;
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
	
	// now add some noise based on our _world_ position
	vec3 noise = texture(noisemap, pos.xz * 0.02).rgb;
	pos.x += (noise.x * 4.0 ) * spacing;
	pos.z += (noise.y * 4.0 ) * spacing;
	
	// apply our height
	pos.y = get_height(pos.xz);
	pos.y -= (noise.x * 0.3 );
	
	float y2 = get_height(pos.xz + vec2(1.0, 0.0));
	float y3 = get_height(pos.xz + vec2(0.0, 1.0));
	vec2 feat_pos = pos.xz;
	feat_pos -= 0.5 * heightmap_size;
	feat_pos /= heightmap_size;
	float terrain_mask = texture(features_map, feat_pos).g + texture(features_map, feat_pos).b;
	
	if (terrain_mask < 0.85) {
		pos.y = -10000.0;
	} else if (abs(y2 - pos.y) > 0.5) {
		pos.y = -10000.0;
	} else if (abs(y3 - pos.y) > 0.5) {
		pos.y = -10000.0;
	}
	
	// rotate our transform
	TRANSFORM[0][0] = cos(noise.z * 3.0);
	TRANSFORM[0][2] = -sin(noise.z * 3.0);
	TRANSFORM[2][0] = sin(noise.z * 3.0);
	TRANSFORM[2][2] = cos(noise.z * 3.0);
	
	//TRANSFORM[1][0] = cos(noise.z * 3.0);
	//TRANSFORM[2][0] = sin(noise.z * 3.5);
	
	// update our transform to place
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
}