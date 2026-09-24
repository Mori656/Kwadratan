extends Node2D

const trade_offer_scene = preload("res://Scenes/Prefabs/trade_offer.tscn")
@onready var gui: Control = $"../CanvasLayer/GUI"
@onready var game_inventory: Node2D = $"../GameInventory"

func create_trade_offer(sender_id,offer,trade_target):
	if trade_target == "bank":
		trade_with_bank(sender_id,offer)
	else:
		rpc("send_offer_to_players",sender_id,offer)
	
@rpc("any_peer","call_local")
func send_offer_to_players(sender_id,offer):
	var offer_container = gui.get_node("OfferContainer")
	if sender_id != multiplayer.get_unique_id():
		var trade_offer = trade_offer_scene.instantiate()
		
		offer_container.add_child(trade_offer)
		trade_offer.set_trade(offer,sender_id)
		trade_offer.position = Vector2(10, 10)
		
		var decline_button = trade_offer.get_node("OfferBox/OfferBoxcontent/DeclineTradeButton")
		decline_button.pressed.connect(decline_offer_handler.bind(trade_offer))
		var accept_button = trade_offer.get_node("OfferBox/OfferBoxcontent/AcceptTradeButton")
		accept_button.pressed.connect(accept_offer_handler.bind(trade_offer,offer,sender_id))
	return

func decline_offer_handler(trade_offer):
	trade_offer.queue_free()
	return

func accept_offer_handler(trade_offer,offer_values,sender_id):
	var player_resources = game_inventory.get_player_resources(multiplayer.get_unique_id())
	if if_player_has_resources(offer_values,player_resources):
		for res in offer_values:
			if offer_values[res] > 0:
				game_inventory.take_resource(multiplayer.get_unique_id(),res,offer_values[res])
				game_inventory.give_resource(sender_id,res,offer_values[res])
			elif offer_values[res] < 0:
				game_inventory.take_resource(sender_id,res,abs(offer_values[res]))
				game_inventory.give_resource(multiplayer.get_unique_id(),res,abs(offer_values[res]))
	game_inventory.update_inventory()
	gui.update_gui()
	rpc("remove_trade_offer", sender_id)		
	return

func if_player_has_resources(offer_values,player_resources):
	for res in player_resources:
		if player_resources[res] < offer_values[res]:
			print("Graczowi brakuje ", res)
			return false
	return true

func trade_with_bank(sender_id,offer_values):
	var player_resources = game_inventory.get_player_resources(sender_id)
	var inventory = game_inventory.get_inventory()
	if if_player_has_resources(offer_values,0):
		for res in offer_values:
			if offer_values[res] > 0:
				game_inventory.take_resource(0,res,offer_values[res])
				game_inventory.give_resource(sender_id,res,offer_values[res])
			elif offer_values[res] < 0:
				game_inventory.take_resource(sender_id,res,abs(offer_values[res]))
				game_inventory.give_resource(0,res,abs(offer_values[res]))
	game_inventory.update_inventory()
	gui.update_gui()	

@rpc("any_peer", "call_local")
func remove_trade_offer(sender_id):
	var offer_container = gui.get_node("OfferContainer")

	for trade_offer in offer_container.get_children():
		if trade_offer.sender_id == sender_id:
			trade_offer.queue_free()
