shader_type canvas_item;

uniform float screen_height = 180;

void fragment() {
	float diff_x = 0.015 * sin((100.0 * UV.y) + (7.0 * TIME));
	COLOR = texture(TEXTURE, vec2(UV.x + diff_x, UV.y));
	COLOR = mix(COLOR, vec4(0.0), float(int(UV.y * screen_height) % 2));
}