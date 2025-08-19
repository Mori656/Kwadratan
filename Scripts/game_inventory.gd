extends Node2D

var inventory = {0:{"resources":{"wood":25, "iron":25, "oil":25, "coal":25, "uran":25},"cards":{}}}
var cards_in_deck = 5
@onready var card_scene = preload("res://Scenes/Prefabs/card.tscn")
@onready var gui = $"../CanvasLayer/GUI"
	
func setup_deck():
	for i in range(cards_in_deck):
		#stworzenie karty
		var new_card = card_scene.instantiate()
		new_card.set_card_info("karta", "fajna karta", "robi")
		#Wstawienie karty do decku
		inventory[0]["cards"][i] = new_card
		
func setup_player_inventory(id):
	var player_inventory = {"resources":{"wood":0, "iron":0, "oil":0, "coal":0, "uran":0},"cards":"karta"}
	inventory[id] = player_inventory
	rpc("update_bank_inventory",inventory)

func on_dice_rolled(res):
	rpc_id(1,"give_resource_to_players_by_dice",res,multiplayer.get_unique_id())

@rpc("any_peer","call_local")
func give_resource_to_players_by_dice(res,requester):
	print("Przydzialanie surowców")
	for player in inventory:
		print("(Przed) Gracz", player, " ma ", inventory[player])
	if take_resource(0, res, 1): # zabieramy 1 surowiec z banku
		give_resource(requester,res,1)
		print("Gracz ", requester, " otrzymał ", res) ## print kto co dostał
	else:
		print("Bank nie ma wystarczającej ilości zasobu: ", res)
	for player in inventory:
		print("Gracz", player, " ma ", inventory[player])
	rpc("update_bank_inventory", inventory)
	gui.update_gui()
	
@rpc("any_peer","call_local")
func update_bank_inventory(new_inventory: Dictionary):
	inventory = new_inventory
		
func take_resource(id: int, res: String, count: int) -> bool:
	if inventory[id]["resources"][res] >= count:
		inventory[id]["resources"][res] -= count
		return true
	else:
		print("nie ma wystarczającej liczby surowca w banku")
	return false
	
func give_resource(id: int, res: String, count: int):
	inventory[id]["resources"][res] += count
	print("Zmieniono ",inventory[id]["resources"][res])
	
func get_player_resources(id: int):
	if inventory.has(id):
		return inventory[id]["resources"]
	else:
		push_error("Player ID %d does not exist in resources." % id)
		return null
	

	
