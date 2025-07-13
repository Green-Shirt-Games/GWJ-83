shader_type canvas_item;

uniform vec2 top_left_offset = vec2(0.0, 0.0);
uniform vec2 top_right_offset = vec2(0.0, 0.0);
uniform vec2 bottom_left_offset = vec2(0.0, 0.0);
uniform vec2 bottom_right_offset = vec2(0.0, 0.0);

void vertex() {
	float u = UV.x;
	float v = UV.y;

	vec2 offset =
		mix(
			mix(top_left_offset, top_right_offset, u),
			mix(bottom_left_offset, bottom_right_offset, u),
			v
		);

	VERTEX += offset;
}
