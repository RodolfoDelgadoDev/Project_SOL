extends Node2D

var Segundos : int
var playerDamage = 10
var currentLevel : String
var levelNumber : int = 0
var plasticoin : int = 0 
var goal: bool = false
var descanso: bool = false
var extra_time : int = 0
var music_on : bool = true
var transicion_bg : int = 0
var ninja_boss : int = 0

func takeDamage(damage):
	Segundos -= damage
	if Segundos <= 0:
		Segundos = 0
		
func reachedGoal(win):
	goal = win
