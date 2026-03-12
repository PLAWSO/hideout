shader_type spatial;

uniform sampler2D noise : filter_nearest;
uniform float signal_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = vec2(mod(UV.x + (TIME * 50.0), 1.0), UV.y);
    vec4 tex = texture(noise, uv);
    ALBEDO = min(0.8 - tex.rgb, 1.0 - signal_strength);
}