
shader_type canvas_item;

void fragment() {
    vec4 left_color  = vec4(0.165, 0.541, 0.251, 1.0);  // #2a8a40
    vec4 right_color = vec4(0.290, 0.910, 0.569, 1.0);  // #4ae891
    COLOR = mix(left_color, right_color, UV.x);
}