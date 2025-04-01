shader_type canvas_item;

instance uniform vec4 top_color: source_color;
instance uniform vec4 bottom_color : source_color;
instance uniform vec4 clicked_color : source_color;

instance uniform bool enabled;

void fragment() {
	if (enabled) {
		float y = UV.y;
		COLOR = mix(top_color, bottom_color, y);
	} else {
		COLOR = clicked_color;
	}
}
