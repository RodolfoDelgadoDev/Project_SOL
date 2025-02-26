extends CanvasLayer

@onready var Animator : AnimationPlayer = $AnimationPlayer

func _ready():
	Animator.play("Scene_Transition_out")

func transition_in() :
	Animator.play("Scene_Transition_in")

func transition_out() :
	Animator.play("Scene_Transition_out")
