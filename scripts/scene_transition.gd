extends CanvasLayer

@export var bgs: Array[Texture] = []
@onready var Animator: AnimationPlayer = $AnimationPlayer
@onready var background: TextureRect = $TextureRect
@export var no_transition: bool = false 

func _ready():
	background.texture = bgs[GameManager.transicion_bg]
	if no_transition == true:
		return
	transition_out()

func transition_in():
	GameManager.transicion_bg = randi_range(0,3)
	print(GameManager.transicion_bg)
	Animator.play("Scene_Transition_in")

func transition_out():
	Animator.play("Scene_Transition_out")
	
