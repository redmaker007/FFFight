
shader_type canvas_item;

void fragment() {
    vec2 grid = fract(UV * vec2(32.0, 18.0)); // 控制网格密度
    float line = step(0.97, grid.x) + step(0.97, grid.y);
    COLOR = vec4(vec3(0.902, 0.784, 0.290) * line * 0.04, 1.0); // #e8c84a极淡
}
