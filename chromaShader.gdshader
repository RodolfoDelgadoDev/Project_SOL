shader_type canvas_item;

// Wobble parameters
uniform float wave_amplitude : hint_range(1, 20) = 1.0;
uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_frequency : hint_range(0.5, 10.0) = 2.0;

// Chromatic aberration parameters
uniform float aberration_amount : hint_range(0, 0.1) = 0.01;
uniform float aberration_speed : hint_range(0, 2.0) = 0.5;

// Glitch parameters
uniform float glitch_intensity : hint_range(0, 1.0) = 0.05;
uniform float glitch_speed : hint_range(0, 5.0) = 1.0;

void fragment() {
    // Base UV with time-based wobble
    vec2 uv = UV;
    float time = TIME * wave_speed;

    // Wobble effect (sinusoidal distortion)
    uv.x += sin(uv.y * wave_frequency + time) * 0.01 * wave_amplitude;
    uv.y += cos(uv.x * wave_frequency + time * 0.7) * 0.01 * wave_amplitude;

    // Chromatic aberration (RGB split)
    float aberration_offset = aberration_amount * sin(time * aberration_speed);
    vec4 color;
    color.r = texture(TEXTURE, vec2(uv.x + aberration_offset, uv.y)).r;
    color.g = texture(TEXTURE, uv).g;
    color.b = texture(TEXTURE, vec2(uv.x - aberration_offset, uv.y)).b;
    color.a = texture(TEXTURE, uv).a;

    // Random glitch effect
    float glitch_threshold = 1.0 - glitch_intensity;
    if (fract(time * glitch_speed * 10.0) > glitch_threshold) {
        vec2 glitch_offset = vec2(
            (fract(sin(time * 100.0) * 43758.5453) - 0.5) * 0.1,
            (fract(cos(time * 80.0) * 23421.631) - 0.5) * 0.1
        ) * glitch_intensity;
        color = texture(TEXTURE, uv + glitch_offset);
    }

    COLOR = color;
}