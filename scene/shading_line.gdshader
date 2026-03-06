shader_type canvas_item;

void fragment() {
    float alpha = sin(UV.x * 3.14159); // 两端淡出
    COLOR = vec4(0.910, 0.784, 0.290, alpha * 0.9);
}


// 4. 标题发光文字

//Label本身不支持发光，用**两层Label叠加**模拟：

//TitleGroup
//├── TitleGlow  (Label) ← 模糊发光层
//└── TitleMain  (Label) ← 清晰主体层