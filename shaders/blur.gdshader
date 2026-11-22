shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 6.0) = 4.0;
uniform float darken: hint_range(0.0, 1.0) = 0.7;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 c = textureLod(screen_tex, SCREEN_UV, blur_amount);
	COLOR = vec4(c.rgb * (1.0 - darken), 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
