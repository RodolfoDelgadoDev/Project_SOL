shader_type canvas_item;

// Ectoplasm color (no hint_color)
uniform vec4 trail_color = vec4(0.3, 0.9, 0.8, 0.6); // Teal with transparency
uniform sampler2D particle_texture; // Texture for the particles

void fragment() {
    // Sample the particle texture
    vec4 texture_color = texture(particle_texture, UV);

    // Apply the trail color and texture alpha
    COLOR = trail_color;
    COLOR.a *= texture_color.a; // Use the texture's alpha channel
}