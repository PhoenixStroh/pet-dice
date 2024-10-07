shader_type spatial;

const int slices = 10;

uniform sampler2D albedo_texture : source_color;

uniform float growth : hint_range(0.0, 1.0, 0.001) = 0.1;

uniform int[8] face_values;

void vertex() {
	VERTEX += NORMAL * growth;
}

void fragment() {
	
	int face_value = face_values[int(floor(UV.y * 10.0))];
	
	vec4 albedo_alpha = texture(albedo_texture, UV + vec2(float(face_value) * (1.0 / float(slices)), 0.0));
	ALBEDO = albedo_alpha.rgb * 0.5;
	EMISSION = ALBEDO;
	ALPHA = albedo_alpha.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
