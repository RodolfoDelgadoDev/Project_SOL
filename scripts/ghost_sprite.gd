extends Sprite2D

# Trail texture settings
var trail_texture: ImageTexture
var trail_image: Image

# Fade factor for the trail
@export var fade_factor: float = 0.95

func _ready() -> void:
	# Initialize the trail texture
	trail_image = Image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_RGBA8)
	trail_texture = ImageTexture.create_from_image(trail_image)
	material.set_shader_parameter("trail_texture", trail_texture)

func _process(delta: float) -> void:
	# Update the trail texture
	update_trail_texture()

func update_trail_texture() -> void:
	# Fade out the trail texture
	trail_image.fill(Color(0, 0, 0, 0)) # Clear the image
	trail_image.lock()

	# Copy the current sprite's pixels to the trail texture
	var sprite_image: Image = texture.get_image()
	sprite_image.lock()

	for x in range(sprite_image.get_width()):
		for y in range(sprite_image.get_height()):
			var color = sprite_image.get_pixel(x, y)
			var trail_color = trail_image.get_pixel(x, y)
			trail_color = trail_color * fade_factor + color * (1.0 - fade_factor)
			trail_image.set_pixel(x, y, trail_color)

	sprite_image.unlock()
	trail_image.unlock()

	# Update the trail texture
	trail_texture.update(trail_image)
