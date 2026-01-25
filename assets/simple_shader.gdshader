/*
NOTES

shader type:
	- canvas_item: 2D
	- spacial: 3D

TIME: global time in seconds since engine started, restarts after 3600.0

uniform: pass in variables fom outside the shader in ever the editor or gd_script

vertex sign
-,- +-----+ +,-
	|     |
-,+	+-----+ +,+

UV coords
0,0 +-----+ 1,0
	|     |
0,1	+-----+ 1,1
*/
shader_type canvas_item;

group_uniforms Speed;
uniform float speed: hint_range(0.0, 5.0, 0.1) = 1.0;

group_uniforms Speed.Color;
uniform vec4 color_a: source_color;
uniform vec4 color_b: source_color;

// called for every vertex the material is visible on.
void vertex() {
	//vec2 offset = vec2(25.0, 25.0);
	//if (VERTEX.x < 0.0 && VERTEX.y < 0.0) {
		//VERTEX += offset * -1.0;
	//} else if (VERTEX.x > 0.0 && VERTEX.y > 0.0 ) {
		//VERTEX += offset;
	//}
	
	// move
	float new_y = 25.0 * -abs(sin(TIME * 5.0));
	//float new_x = 25.0 * cos(TIME * 5.0);
	//VERTEX += vec2(0.0, new_y);
}

// called for every pixel the material is visible on.
void fragment() {
	//vec4 red = vec4(1.0, 0.0, 0.0, 1.0);
	//vec4 green = vec4(0.0, 1.0, 0.0, 1.0);
	
	float mix_smooth = (1.0 + sin(TIME * speed)) * 0.5;
	vec4 lerp_color = mix(color_a, color_b, mix_smooth);
	
	// sample texture color usingh texture(TEXTURE, UV)
	//COLOR = vec4(UV.rg, 0.0, 1.0); // print UV 
	COLOR = texture(TEXTURE, UV) * lerp_color; // out color
}