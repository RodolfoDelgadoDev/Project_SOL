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
	#GameManager.descanso = descanso
	var current_scene = get_tree().current_scene.scene_file_path
	GameManager.currentLevel = current_scene
	print(current_scene)
	GameManager.Segundos = segundos
	for child in get_children():
		if child.is_in_group("pickup"):
			bottleTotal += 1
	print("Total bottles found: ", bottleTotal)
	if descanso:
		timer.stop_timer()
		toggle_timer()
		reciclaje()

# Add a bottle and check if all bottles are collected
func addBottle():
	bottleNum += 1
	print(bottleNum)
	if bottleNum == bottleTotal:
		print("bien ahi")
		allBottles = true

# Change scene with transition
func change_scene():
	if descanso == true:
		chooseTargetScene()
	if not animation_player.is_connected("animation_finished", _on_TransitionAnimation_finished):
		GameManager.plasticoin += bottleNum
		animation_player.animation_finished.connect(_on_TransitionAnimation_finished)  # Connect the signal only if not already connected
	animation_player.play("Scene_Transition_in")  # Start the transition animation

# Function to handle the scene change after the animation finishes
func _on_TransitionAnimation_finished(animation_name: String):
	if animation_name == "Scene_Transition_in":  # Check if the finished animation is the one we want
		chooseTargetScene()
		print(targetScene)
		get_tree().change_scene_to_file(targetScene)  # Change to the new scene
		animation_player.animation_finished.disconnect(_on_TransitionAnimation_finished)  # Disconnect the signal to avoid multiple calls

func game_over():
	bottleNum = 0
	allBottles = false
	targetScene = "res://Scenes/GameOverUpdate.tscn"
	change_scene()

func chooseTargetScene():
	if descanso == true:
		print(GameManager.currentLevel)
		if GameManager.levelNumber == 1:
			targetScene = "res://Scenes/Levels/edificio.tscn"
		if GameManager.levelNumber == 2:
			targetScene = ("res://Scenes/Levels/edificio2.tscn")
		if GameManager.levelNumber == 3:
			targetScene = ("res://Scenes/Levels/edificio3.tscn")
		if GameManager.levelNumber == 4:
			targetScene = ("res://Scenes/Levels/complejo.tscn")
		if GameManager.levelNumber == 5:
			targetScene = ("res://Scenes/Levels/complejo2.tscn")
		if GameManager.levelNumber == 6:
			targetScene = ("res://Scenes/Levels/bosque.tscn")
		if GameManager.levelNumber == 7:
			targetScene = ("res://Scenes/Levels/bosque2.tscn")

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
