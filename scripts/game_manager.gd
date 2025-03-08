extends Node2D

var Segundos : int
var playerDamage = 10
var currentLevel
var plasticoin : int = 0 ##moneda que te dan por completar un nivel con todas las botellas
	
func takeDamage(damage):
	Segundos -= damage
	if Segundos <= 0:
		Segundos = 0
		var enemies = get_tree().get_nodes_in_group("enemy")
		print(enemies)
