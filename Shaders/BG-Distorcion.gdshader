shader_type canvas_item;

uniform float screen_height = 1.0;

void fragment() {
	float diff_x = 0.075 * sin((10.0 * UV.y) + (2.0 * TIME));
	COLOR = texture(TEXTURE, vec2(UV.x + diff_x, UV.y));
	COLOR = mix(COLOR, vec4(0.0), float(int(UV.y * screen_height) % 2));
}