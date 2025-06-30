shader_type canvas_item;

uniform float circle_size : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	if (distance(UV, vec2(0.5, 0.5)) < circle_size) {
		COLOR.a = 0.0;
	}
}
