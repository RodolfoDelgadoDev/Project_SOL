extends Node2D

var Segundos : int
var playerDamage = 10
	
func takeDamage(damage):
	Segundos -= damage
	if Segundos <= 0:
		Segundos = 0
