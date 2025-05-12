extends Node2D

@export var barra: ColorRect
@export var modo_ataque: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(body: Node2D) -> void:
	barra.appear()
	print("barra_coso funca")
	if modo_ataque == true:
		var Scene_Manager = get_parent()
		Scene_Manager.descanso = false
		Scene_Manager.start_timer()
		Scene_Manager.toggle_timer()
		
	queue_free()
