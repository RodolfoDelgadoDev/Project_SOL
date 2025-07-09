extends Node2D

# Este nodo maneja los elementos de la escena, el timer, cuantas botellas hay, etc.
@export var segundos: int
@export var descanso: bool # if true = indica que estás en la sala de descanso
@export var targetScene: NodePath
@onready var timer: Node2D = $CanvasLayer/Timer
@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer  # Assuming you have an AnimationPlayer
@onready var DialogueBox: Node2D = $CanvasLayer/DialogueBox
@onready var Player: Node2D = $Player

var pause_scene_path: String = "res://Scenes/GameOverUpdate.tscn"

var pause_scene_instance: Control = null
var is_paused: bool = false
var tween: Tween = null
var bottleNum: int = 0
var bottleTotal: int
var allBottles: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_scene = get_tree().current_scene.scene_file_path
	GameManager.currentLevel = current_scene
	print(current_scene)
	GameManager.Segundos = segundos + GameManager.extra_time
	print(segundos + GameManager.extra_time)
	for child in get_children():
		if child.is_in_group("pickup"):
			bottleTotal += 1
	print("Total bottles found: ", bottleTotal)
	if descanso == true:
		print("modo descanso activado")
		stop_timer()
		toggle_timer() #deja invisible el timer
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("scene_manager")

# Add a bottle and check if all bottles are collected
func addBottle():
	bottleNum += 1
	print(bottleNum)
	if bottleNum == bottleTotal:
		print("bien ahi")
		allBottles = true

func change_scene():
	if descanso == true:
		chooseTargetScene()  # Set the targetScene first
		print("Changing to: ", targetScene)
	if not animation_player.is_connected("animation_finished", _on_TransitionAnimation_finished):
		animation_player.animation_finished.connect(_on_TransitionAnimation_finished)    
	SceneTransition.transition_in()

func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":
		print("Transition finished, loading: ", targetScene)
		# Verify the scene exists before loading
		if ResourceLoader.exists(targetScene):
			get_tree().change_scene_to_file(targetScene)
		else:
			printerr("Scene not found: ", targetScene)
			# Fallback to a default scene if needed
			targetScene = "res://Scenes/Levels/edificio.tscn"
			get_tree().change_scene_to_file(targetScene)
		
		animation_player.animation_finished.disconnect(_on_TransitionAnimation_finished)

func chooseTargetScene():
	if descanso:
		match GameManager.levelNumber:
			1:
				targetScene = "res://Scenes/Levels/edificio.tscn"
			2:
				targetScene = "res://Scenes/Levels/edificio2.tscn"
			3:
				targetScene = "res://Scenes/Levels/edificio3.tscn"
			4:
				targetScene = "res://Scenes/Levels/complejo.tscn"
			5:
				targetScene = "res://Scenes/Levels/complejo2.tscn"
			6:
				targetScene = "res://Scenes/Levels/bosque.tscn"
			7:
				targetScene = "res://Scenes/Levels/bosque2.tscn"
			8:
				targetScene = "res://Scenes/Levels/Bossfight.tscn"
			_:
				targetScene = "res://Scenes/Levels/edificio.tscn"
				printerr("Unexpected level number, defaulting to level 1")
		print("Current level number: ", GameManager.levelNumber)
	if not descanso:
		match GameManager.plasticoin:
			0:
				targetScene = "res://Scenes/Levels/Descansos/descanso0.tscn"
			1:
				targetScene = "res://Scenes/Levels/Descansos/descanso1.tscn"
			2:
				targetScene = "res://Scenes/Levels/Descansos/descanso2.tscn"
			3:
				targetScene = "res://Scenes/Levels/Descansos/descanso3.tscn"
			4:
				targetScene = "res://Scenes/Levels/Descansos/descanso4.tscn"
			5:
				targetScene = "res://Scenes/Levels/Descansos/descanso5.tscn"
			6:
				targetScene = "res://Scenes/Levels/Descansos/descanso6.tscn"
			7:
				targetScene = "res://Scenes/Levels/Descansos/descanso7.tscn"

	print("Selected target scene: ", targetScene)

func game_over():
	targetScene = GameManager.currentLevel
	bottleNum = 0
	allBottles = false
	change_scene()

func stop_timer():
	timer.stop_timer()
	
func start_timer():
	timer.start_timer()

func toggle_timer():
	if timer.visible == false:
		timer.visible = true
	else:
		timer.visible = false
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if pause_scene_path.is_empty():
			printerr("No pause scene path set!")
			return
			
		if is_paused:
			unpause_game()
		else:
			pause_game()

func pause_game():
	if is_paused or pause_scene_path.is_empty():
		return
		
	is_paused = true
	get_tree().paused = true
	if not descanso:
		stop_timer()
	Player.stop_movement()
	
	# Load and instance the pause scene
	var pause_scene = load(pause_scene_path)
	if pause_scene:
		pause_scene_instance = pause_scene.instantiate()
		$CanvasLayer.add_child(pause_scene_instance)
		
		# Set initial state for animation
		pause_scene_instance.modulate.a = 0
		pause_scene_instance.scale = Vector2(0.9, 0.9)
		
		# Create tween animation
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(pause_scene_instance, "modulate:a", 1.0, 0.1)
		tween.parallel().tween_property(pause_scene_instance, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		printerr("Failed to load pause scene at path: ", pause_scene_path)
		is_paused = false
		get_tree().paused = false

func unpause_game():
	if not is_paused or not pause_scene_instance:
		return
		
	# Animate out
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(pause_scene_instance, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(pause_scene_instance, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_callback(_remove_pause_scene)
	
	is_paused = false
	get_tree().paused = false
	if not descanso:
		start_timer()
	Player.resume_movement()

func _remove_pause_scene():
	if pause_scene_instance:
		pause_scene_instance.queue_free()
		pause_scene_instance = null
