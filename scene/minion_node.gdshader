shader_type canvas_item;

// 可以在编辑器里选颜色，默认纯白
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// 0.0 是原色，1.0 是纯白
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// 获取原本贴图的颜色
	vec4 color = texture(TEXTURE, UV);
	
	// 将原本的颜色(rgb) 和 闪光颜色(rgb) 进行混合
	// mix(A, B, weight): weight越接近1，结果越接近B
	color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);
	
	// 输出最终颜色
	COLOR = color;
}