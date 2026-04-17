shader_type canvas_item;
// canvas: 2d shader
render_mode blend_mix;

// capture current screen
uniform sampler2D screen_texture: source_color, filter_linear_mipmap, hint_screen_texture;
// blur amount
uniform float blur_strengh : hint_range(0.0, 4.0, 0.01) = 2.0;

void fragment()
{
	COLOR.rgb = textureLod(screen_texture, SCREEN_UV, blur_strengh).rgb;
}
