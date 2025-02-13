extends Node2D

var Segundos = 30
	
func takeDamage(damage):
	Segundos -= damage
	if Segundos <= 0:
		Segundos = 0
