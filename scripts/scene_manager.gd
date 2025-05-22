extends Node2D

# Este nodo maneja los elementos de la escena, el timer, cuantas botellas hay, etc.
@export var segundos: int
@export var descanso: bool # if true = indica que estás en la sala de descanso
@export var targetScene: NodePath
@onready var timer: Node2D = $CanvasLayer/Timer
@onready var SceneTransition: CanvasLayer = $Scene_Transition
@onready var animation_player: AnimationPlayer = $Scene_Transition/AnimationPlayer  # Assuming you have an AnimationPlayer
@onready var DialogueBox: Node2D = $CanvasLayer/DialogueBox

@export var sec1: Node2D
@export var sec2: Node2D
@export var sec3: Node2D
@export var sec4: Node2D
@export var sec5: Node2D
@export var sec6: Node2D
@export var hide_visuals: Node2D

var bottleNum: int = 0
var bottleTotal: int
var allBottles: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_scene = get_tree().current_scene.scene_file_path
	GameManager.currentLevel = current_scene
	print(current_scene)
	GameManager.Segundos = segundos
	for child in get_children():
		if child.is_in_group("pickup"):
			bottleTotal += 1
	print("Total bottles found: ", bottleTotal)
	if descanso == true:
		print("modo descanso activado")
		stop_timer()
		toggle_timer()
		reciclaje()

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
		GameManager.plasticoin += bottleNum
		animation_player.animation_finished.connect(_on_TransitionAnimation_finished)    
	animation_player.play("Scene_Transition_in")

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
	if not descanso:
		return
		
	print("Current level number: ", GameManager.levelNumber)
	
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
		_:
			targetScene = "res://Scenes/Levels/edificio.tscn"
			printerr("Unexpected level number, defaulting to level 1")
	
	print("Selected target scene: ", targetScene)

func game_over():
	targetScene = "res://Scenes/GameOverUpdate.tscn"
	bottleNum = 0
	allBottles = false
	change_scene()

func stop_timer():
	timer.stop_timer()
	
func start_timer():
	timer.start_timer()
	
func reciclaje():
	print("plasticoin totales...")
	print(GameManager.plasticoin)
	if GameManager.plasticoin > 1:
		sec1.visible = true
		hide_visuals.visible = false
		if GameManager.plasticoin > 2:
			sec2.visible = true
			if GameManager.plasticoin > 3:
				sec3.visible = true
				if GameManager.plasticoin > 4:
					sec4.visible = true
					if GameManager.plasticoin > 5:
						sec5.visible = true
						if GameManager.plasticoin > 6:
							sec6.visible = true
					
func toggle_timer():
	if timer.visible == false:
		timer.visible = true
	else:
		timer.visible = false
