extends Node2D

@onready var game_inventory: Node2D = $"../GameInventory"
@onready var gui: Control = $"../CanvasLayer/GUI"

### Dice ###
# Dice events
func on_dice_rolled(res):
	rpc_id(1,"give_resource_to_players_by_dice",res,multiplayer.get_unique_id())
	
# Przydzielanie surowców na podstawie kosći
@rpc("any_peer", "call_local")
func give_resource_to_players_by_dice(res: String, requester: int, amount: int): # Dodano parametr amount
	if not multiplayer.is_server(): 
		return
	print("--- Przydzielanie surowców ---")
	# Sprawdzamy dostępność w banku (ID 0)
	var available_in_bank = game_inventory.inventory[0]["resources"][res]
	var final_amount = min(amount, available_in_bank) 	# dajemy maksymalną ilość jaką się da
	
	if final_amount > 0:
		if game_inventory.take_resource(0, res, final_amount): # zabieramy z banku
			game_inventory.give_resource(requester, res, final_amount) # dajemy graczowi (peer_id)
			print("Gracz ", requester, " otrzymał ", final_amount, "x ", res)
	else:
		print("Bank nie ma surowca: ", res)

	# Synchronizacja całości
	game_inventory.update_inventory()
	gui.update_gui()
