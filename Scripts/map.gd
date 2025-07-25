extends Node

var numbers_pool = []
var resource_pool = []

func _ready():
	print("Załadowano mapę")
	roll_and_set_numbers()
	roll_and_set_resources()
	
func roll_and_set_numbers():
	if numbers_pool.is_empty():
		numbers_pool = [1,2,3,4,5,6,7,8,9,10,11,12]
		numbers_pool.shuffle()
		
	for tile in $tiles.get_children():
		if tile.active:
			if numbers_pool.is_empty():
				# Resetowanie puli
				numbers_pool = [1,2,3,4,5,6,7,8,9,10,11,12]
				numbers_pool.shuffle()

			var number = numbers_pool.pop_back()
			tile.set_value(number)
	print("Losowanie liczb na polach")
	
func roll_and_set_resources():
	if resource_pool.is_empty():
		resource_pool = [1,2,3,4,5]
		resource_pool.shuffle()
		
	for tile in $tiles.get_children():
		if tile.active:
			if resource_pool.is_empty():
				# Resetowanie puli
				resource_pool = [1,2,3,4,5]
				resource_pool.shuffle()

			var resource = resource_pool.pop_back()
			tile.set_resource(resource)
	print("Losowanie surowców na polach")
