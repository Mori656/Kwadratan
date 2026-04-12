extends Node2D

@onready var gui: Control = $"../CanvasLayer/GUI"
@onready var game_inventory: Node2D = $"../GameInventory"
var cards_in_deck = 10
var inventory

### Cards ###
# Setup
func setup_deck():
	for i in range(cards_in_deck):
		#Wstawienie karty do decku
		var card = {"id":i,"title":"karta","desc":"to jest karta","fun":"add_wood"}
		inventory = game_inventory.inventory
		inventory[0]["cards"].append(card)

# Cards events
func on_card_draw():
	rpc_id(1,"give_card_to_player",multiplayer.get_unique_id())

func on_card_used(id):
	rpc_id(1,"remove_used_card",multiplayer.get_unique_id(),id)

func on_card_used_add_resource(res):
	rpc_id(1,"give_resource_to_players_by_card",res,multiplayer.get_unique_id())

# Funckja przydzialnia karty do gracza
@rpc("any_peer","call_local")
func give_card_to_player(requester):
	if inventory[0]["cards"].size() > 0:
		inventory[requester]["cards"].append(inventory[0]["cards"].pop_front())
		game_inventory.update_inventory(inventory)
		gui.update_gui()
		
# Przydialenie surowców na podstaawie card
@rpc("any_peer","call_local")
func give_resource_to_players_by_card(res,requester):
	if game_inventory.take_resource(0, res, 1): # zabieramy 1 surowiec z banku
		game_inventory.give_resource(requester,res,1)
	else:
		print("Bank nie ma wystarczającej ilości zasobu: ", res)
	game_inventory.update_inventory(inventory)
	gui.update_gui()
	
# Usunięcie(Po użyciu) karty 
@rpc("any_peer","call_local")
func remove_used_card(requester,card_id):
	for card in inventory[requester]["cards"]:
		print(card)
		if card["id"] == card_id:
			inventory[requester]["cards"].erase(card)
			game_inventory.update_inventory(inventory)
			gui.update_gui()
			return null
			
# Pobranie kart gracza
@rpc("any_peer","call_local")
func get_player_cards(id: int):
	print("wez karty ", multiplayer.get_unique_id())
	print(game_inventory.inventory)
	print(game_inventory.inventory.has(id))
	if game_inventory.inventory.has(id):
		return game_inventory.inventory[id]["cards"]
	else:
		push_error("Nie znaleziono kart gracza od ID %d" % id)
		return null
