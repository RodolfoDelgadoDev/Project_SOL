extends Node

var Segundos = 30

# Called when the node enters the scene tree for the first time.
	
func takeDamage(damage):
	Segundos -= damage
	
