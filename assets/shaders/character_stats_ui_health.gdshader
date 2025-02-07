shader_type canvas_item;

uniform float glow_intensity : hint_range(0.0, 2.0);
uniform float pulse_speed : hint_range(0.0, 5.0);
uniform vec4 fill_color : source_color;

void fragment() {
    vec2 uv = UV;
    vec4 tex_color = texture(TEXTURE, uv);

    // Create a pulsing effect
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

    // Apply glow effect across the entire bar
    float glow = glow_intensity * pulse;

    // Final color output: fill color + glow effect
    vec4 final_color = fill_color * tex_color.a; // Keep original alpha
    final_color.rgb += glow * fill_color.rgb; // Add glow effect

    COLOR = final_color;
}
