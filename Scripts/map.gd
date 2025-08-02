extends Node

var numbers_pool = []
var resource_pool = []

func _ready():
	if multiplayer.is_server():
		print("Załadowano mapę na serwerze")
		roll_and_set_numbers()
		roll_and_set_resources()

func roll_and_set_numbers():
	if numbers_pool.is_empty():
		numbers_pool = [1,2,3,4,5,6,7,8,9,10,11,12]
		numbers_pool.shuffle()

	var rolled_numbers = []

	for tile in $tiles.get_children():
		if tile.active:
			if numbers_pool.is_empty():
				numbers_pool = [1,2,3,4,5,6,7,8,9,10,11,12]
				numbers_pool.shuffle()

			var number = numbers_pool.pop_back()
			rolled_numbers.append(number)
			tile.set_value(number)

	# Przekazanie danych do klientów
	rpc("apply_rolled_numbers", rolled_numbers)
	print("Losowanie liczb na polach")

@rpc("authority", "call_remote")
func apply_rolled_numbers(numbers: Array):
	var i = 0
	for tile in $tiles.get_children():
		if tile.active and i < numbers.size():
			tile.set_value(numbers[i])
			i += 1

func roll_and_set_resources():
	if resource_pool.is_empty():
		resource_pool = [1,2,3,4,5]
		resource_pool.shuffle()

	var rolled_resources = []

	for tile in $tiles.get_children():
		if tile.active:
			if resource_pool.is_empty():
				resource_pool = [1,2,3,4,5]
				resource_pool.shuffle()

			var resource = resource_pool.pop_back()
			rolled_resources.append(resource)
			tile.set_resource(resource)

	rpc("apply_rolled_resources", rolled_resources)
	print("Losowanie surowców na polach")
	
@rpc("authority", "call_remote")
func apply_rolled_resources(resources: Array):
	var i = 0
	for tile in $tiles.get_children():
		if tile.active and i < resources.size():
			tile.set_resource(resources[i])
			i += 1
