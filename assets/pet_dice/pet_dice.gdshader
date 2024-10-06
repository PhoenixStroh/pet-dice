shader_type spatial;

uniform sampler2D albedo_texture : source_color;

void fragment() {
	
	ALBEDO = texture(albedo_texture, UV).rgb * 0.5;
	EMISSION = ALBEDO;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
