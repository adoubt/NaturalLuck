extends Control
var balance:float
var relicts : Array[Relic]
var consumables : Array[Consumable]

var hand: Array[Animal]
var chosen_animals: Array[Animal]
var enemies:Array[Enemy]
var chosen_enemies: Array[Animal]
var hints: Array[Hint]
var showed_hints:Array[Hint]
var current_round:int
var debt:float

func game():
	pass

func chose_animal():
	pass
func battle():
	pass

func split_deposit(deposit_ratio:float):
	var round_deposit:float = (balance * deposit_ratio)
	for animal in chosen_animals:
		animal.balance += round_deposit/chosen_animals.size()
		
