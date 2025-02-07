extends Camera2D

# Player node to follow
@export var player_path: NodePath
var player: Node2D

func _ready():
	# Get the player node from the scene
	if has_node(player_path):
		player = get_node(player_path)
	else:
		print("Player path not set for camera. Please set the player_path in the inspector.")

# Called every frame
func _process(delta):
	if player:
		# Directly set the camera's position to the player's global position
		global_position = player.global_position
