extends Node2D

var Segundos : int
var playerDamage = 10
var currentLevel
	
func takeDamage(damage):
	Segundos -= damage
	if Segundos <= 0:
		Segundos = 0
