extends PointLight2D

# Exported variables to control the color change interval
@export var change_time: float = 3
@export var appear_duration: float = 0.2
@export var disappear_duration: float = 0.5

@onready var timer: Timer = $Timer
var tween: Tween

# Internal variables
var current_color: Color = Color(1, 1, 1, 1)
var target_color: Color
var time_elapsed: float = 0.0
var original_energy: float
var original_scale: Vector2

func _ready():
	# Store original properties
	original_energy = energy
	original_scale = scale
	
	# Set initial target color
	set_random_target_color()
	change_time += randf_range(-0.2, 0.2)
	
	#spawnea un poquito corrida de lugar
	var random_offset = randf_range(0.5, 5)
	self.global_position += Vector2(random_offset, random_offset)
	
	# Animate appearance
	animate_appear()

func animate_appear():
	# Reset properties for appearance animation
	energy = 0
	scale = Vector2.ZERO
	visible = true
	
	# Stop any existing tweens
	if tween and tween.is_valid():
		tween.kill()
	
	# Create new tween for appearance
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "energy", original_energy, appear_duration)
	tween.parallel().tween_property(self, "scale", original_scale, appear_duration)

func animate_disappear():
	# Stop any existing tweens
	if tween and tween.is_valid():
		tween.kill()
	
	# Create new tween for disappearance
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "energy", 0, disappear_duration)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, disappear_duration)
	tween.tween_callback(queue_free)

func set_random_target_color():
	target_color = Color(randf(), randf(), randf(), 1.0)

func _process(delta):
	# Only process color changes if we're visible
	if not visible:
		return
		
	time_elapsed += delta
	var t = min(time_elapsed / change_time, 1.0)

	current_color.r = lerp(current_color.r, target_color.r, t)
	current_color.g = lerp(current_color.g, target_color.g, t)
	current_color.b = lerp(current_color.b, target_color.b, t)
	self.color = current_color

	if time_elapsed >= change_time:
		time_elapsed = 0.0
		current_color = target_color
		set_random_target_color()

func _on_timer_timeout():
	animate_disappear()
