extends PointLight2D

# Exported variables to control the color change interval
@export var change_time: float = 2

# Internal variables
var current_color: Color = Color(1, 1, 1, 1)  # Starting color (white)
var target_color: Color
var time_elapsed: float = 0.0

func _ready():
	# Set the initial target color
	set_random_target_color()
	change_time += randf_range(-0.2, 0.2)

func set_random_target_color():
	# Generate a new random target color (RGB values between 0 and 1, alpha always 1)
	target_color = Color(randf(), randf(), randf(), 1.0)

func _process(delta):
	# Accumulate time elapsed
	time_elapsed += delta

	# Calculate the interpolation factor (0 to 1)
	var t = min(time_elapsed / change_time, 1.0)

	# Interpolate the current color towards the target color
	current_color.r = lerp(current_color.r, target_color.r, t)
	current_color.g = lerp(current_color.g, target_color.g, t)
	current_color.b = lerp(current_color.b, target_color.b, t)

	# Apply the interpolated color to the light
	self.color = current_color

	# Check if the interpolation is complete
	if time_elapsed >= change_time:
		# Reset the elapsed time
		time_elapsed = 0.0

		# Set the current color to the target color (to avoid snapping)
		current_color = target_color

		# Set a new random target color
		set_random_target_color()
