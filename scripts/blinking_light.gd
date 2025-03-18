extends PointLight2D

# Exported variables to control the blink interval range
@export var blink_interval_min: float = 0.5
@export var blink_interval_max: float = 2.0

# Internal variables
var blink_interval: float
var time_elapsed: float = 0.0
var is_light_on: bool = true

func _ready():
	# Set the initial blink interval
	set_random_blink_interval()

func set_random_blink_interval():
	# Generate a random blink interval between the min and max values
	blink_interval = randf_range(blink_interval_min, blink_interval_max)

func _process(delta):
	# Accumulate time elapsed
	time_elapsed += delta

	# Check if the blink interval has passed
	if time_elapsed >= blink_interval:
		# Toggle the light's visibility
		is_light_on = !is_light_on
		visible = is_light_on

		# Reset the elapsed time and set a new random blink interval
		time_elapsed = 0.0
		set_random_blink_interval()
