extends Node2D

var Segundos : int
var playerDamage = 10
var currentLevel : String
var levelNumber : int = 0
var plasticoin : int = 0 
var goal: bool = false
var descanso: bool = false

func takeDamage(damage):
	Segundos -= damage
	if Segundos <= 0:
		Segundos = 0
		var enemies = get_tree().get_nodes_in_group("enemy")
		print(enemies)
		
func reachedGoal(win):
	goal = win
