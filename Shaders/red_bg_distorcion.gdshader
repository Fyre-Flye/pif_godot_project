shader_type canvas_item;

uniform float screen_height = 180;

void fragment() {
	float diff_y = 0.015 * sin((20.0 * UV.y) + (3.0 * TIME));
	COLOR = texture(TEXTURE, vec2(UV.y + diff_y, UV.x));
	COLOR = mix(COLOR, vec4(0.0), float(int(UV.y * screen_height) % 2));
}