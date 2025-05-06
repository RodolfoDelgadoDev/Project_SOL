extends ColorRect

# Animation Settings
@export var bounce_height: float = 4.0  # Subtle bounce amount
@export var bounce_speed: float = 1.5
@export var enter_speed: float = 800.0  # Speed when entering
@export var exit_speed: float = 500.0   # Speed when exiting
@export var showup: bool = false

# State
var target_position: Vector2
var tween: Tween
var is_visible: bool = false

func _ready():
	target_position = position
	position.y += 500  # Start 500px below (offscreen)
	hide()
	if showup == true:
		appear()

# Public functions
func appear():
	if is_visible: return
	is_visible = true
	
	show()
	if tween:
		tween.kill()
	
	# Enter animation - comes up from bottom
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 
		target_position.y, 
		calculate_duration(500, enter_speed)
	)
	tween.tween_callback(start_bounce_animation)

func disappear():
	if !is_visible: return
	is_visible = false
	
	if tween:
		tween.kill()
	
	# Exit animation - goes back down
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", 
		target_position.y + 500, 
		calculate_duration(500, exit_speed)
	)
	tween.tween_callback(queue_free)

# Helper function for consistent animation speed
func calculate_duration(distance: float, speed: float) -> float:
	return distance / speed

# Animation functions
func start_bounce_animation():
	if tween:
		tween.kill()
	
	tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	
	# Subtle 3-phase bounce
	tween.tween_property(self, "position:y", 
		target_position.y - bounce_height * 0.3, 
		0.6/bounce_speed
	).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "position:y", 
		target_position.y + bounce_height * 0.1, 
		0.8/bounce_speed
	).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "position:y", 
		target_position.y, 
		0.6/bounce_speed
	).set_ease(Tween.EASE_IN_OUT)
	
	await_input()

func await_input():
	while is_visible:
		if Input.is_anything_pressed():
			var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			if input_vector != Vector2.ZERO:
				await get_tree().create_timer(1.2).timeout
				disappear()
				break
		await get_tree().process_frame
