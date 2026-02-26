shader_type canvas_item;

uniform float line_spacing : hint_range(2.0, 6.0) = 3.0;
uniform float line_opacity : hint_range(0.0, 0.1) = 0.03;

void fragment() {
    float line = mod(FRAGCOORD.y, line_spacing);
    float dark = step(line_spacing - 1.0, line) * line_opacity;
    COLOR = vec4(0.0, 0.0, 0.0, dark);
}