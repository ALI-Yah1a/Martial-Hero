
shader_type canvas_item;

uniform vec4 light_color : source_color = vec4(1.0, 0.78, 0.40, 1.0);
uniform float light_strength : hint_range(0.0, 0.3) = 0.07;
uniform float movement_speed : hint_range(0.0, 1.0) = 0.12;
uniform float light_size : hint_range(0.1, 1.0) = 0.45;

void fragment() {
    vec2 uv = UV;

    vec2 light_pos = vec2(
        0.5 + sin(TIME * movement_speed) * 0.15,
        0.35 + cos(TIME * movement_speed * 0.7) * 0.08
    );

    float distance_to_light = distance(uv, light_pos);
    float light_mask = 1.0 - smoothstep(
        0.0, light_size, distance_to_light
    );

    vec4 base = texture(TEXTURE, UV) * COLOR;
    base.rgb += light_color.rgb * light_mask * light_strength;

    COLOR = base;
}
