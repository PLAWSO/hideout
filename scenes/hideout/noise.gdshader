shader_type canvas_item;

uniform sampler2D noise : filter_nearest;
uniform float opacity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	
	COLOR = texture(noise, vec2(mod(UV.r + (TIME * 50.0), 1.0), UV.g));
	COLOR.a = opacity;
}
