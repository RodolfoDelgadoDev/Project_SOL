extends CanvasLayer

@export var bgs: Array[Texture] = []
@onready var Animator: AnimationPlayer = $AnimationPlayer
@onready var background: TextureRect = $TextureRect
@export var no_transition: bool = false

func _ready():
	if bgs.size() == 0:
		return  # Avoid errors if array is empty
	
	# Set initial texture (from GameManager or random)
	background.texture = bgs[GameManager.transicion_bg]
	
	if no_transition:
		return
	transition_out()

func transition_in():
	# Change texture BEFORE playing animation (if needed)
	background.texture = bgs[GameManager.transicion_bg]
	Animator.play("Scene_Transition_in")

func transition_out():
	# Pick a new random background (different from current)
	var new_bg = randi_range(0, bgs.size() - 1)
	while new_bg == GameManager.transicion_bg:
		new_bg = randi_range(0, bgs.size() - 1)
	
	GameManager.transicion_bg = new_bg
	Animator.play("Scene_Transition_out")
