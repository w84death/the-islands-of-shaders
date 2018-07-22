shader_type spatial;
//render_mode cull_disabled;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

//render_mode depth_draw_alpha_prepass;


uniform float amplitude = 0.2;
uniform vec2 speed = vec2(2.0, 1.5);
uniform vec2 scale = vec2(0.1, 0.2);

uniform sampler2D tex_albedo : hint_albedo;
uniform sampler2D tex_ao : hint_albedo;
uniform sampler2D tex_nrm : hint_normal;
uniform sampler2D tex_spec;
uniform sampler2D tex_rgh;


void vertex() {
	if (VERTEX.y > 0.0) {
		vec3 worldpos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
		VERTEX.x += amplitude * sin(worldpos.x * scale.x * 0.75 + TIME * speed.x) * cos(worldpos.z * scale.x + TIME * speed.x * 0.25);
		VERTEX.z += amplitude * sin(worldpos.x * scale.y + TIME * speed.y * 0.35) * cos(worldpos.z * scale.y * 0.80 + TIME * speed.y);
	}
}

void fragment() {
	vec4 color = texture(tex_albedo, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a;
	ALPHA_SCISSOR = 0.7;
	
	SPECULAR = texture(tex_spec, UV).r;
	ROUGHNESS = texture(tex_rgh, UV).r;
	METALLIC = 0.75;
	NORMALMAP = texture(tex_nrm, UV).rgb;
	NORMALMAP_DEPTH = -1.0;
}

