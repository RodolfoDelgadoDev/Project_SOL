shader_type canvas_item;

// Parameters for the undulation effect
uniform float wave_amplitude : hint_range(0.0, 20.0) = 5.0;
uniform float wave_frequency : hint_range(0.0, 10.0) = 3.0;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.0;

// Transparency
uniform float transparency : hint_range(0.0, 1.0) = 0.7;

void vertex() {
    // Apply a waving effect to the sprite's vertices
    float wave = sin(VERTEX.y * wave_frequency + TIME * wave_speed) * wave_amplitude;
    VERTEX.x += wave;

    // Add a vertical undulation effect
    float undulation = cos(VERTEX.x * 0.1 + TIME * wave_speed * 1.5) * wave_amplitude * 0.5;
    VERTEX.y += undulation;
}

void fragment() {
    // Sample the sprite's texture
    vec4 color = texture(TEXTURE, UV);
    // Apply transparency
    color.a *= transparency;

	color.rgb = mix(color.rgb, vec3(0.3, 0.9, 0.8), 0.5);
    // Output the final color
    COLOR = color;
}