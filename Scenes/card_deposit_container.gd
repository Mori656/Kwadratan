extends Area2D

@onready var inventory = $"../../../GameInventory"

func on_card_dropped(card:CardNode):
	var callable = Callable(self, card["fun"])

	if callable.is_valid():
		callable.call()
	else:
		push_error("Funckja nierozpoznana: " + str(card["fun"]))
	pass
	
func add_wood():
	inventory.on_card_used_add_resource("wood")
