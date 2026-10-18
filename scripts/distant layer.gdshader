
shader_type canvas_item;
render_mode unshaded;

uniform float zoom_level : hint_range(1.0, 1.4) = 1.12;
uniform float drift_speed : hint_range(0.0, 2.0) = 0.35;
uniform float drift_amount : hint_range(0.0, 0.1) = 0.025;
uniform float vertical_speed : hint_range(0.0, 2.0) = 0.22;
uniform float vertical_amount : hint_range(0.0, 0.1) = 0.012;

void fragment() {
    vec2 uv = (UV - vec2(0.5)) / zoom_level + vec2(0.5);

    uv.x += sin(TIME * drift_speed) * drift_amount;
    uv.y += cos(TIME * vertical_speed) * vertical_amount;

    COLOR = texture(TEXTURE, uv);
}
