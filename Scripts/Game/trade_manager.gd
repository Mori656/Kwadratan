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

func accept_offer_handler(_trade_offer, offer_values, sender_id):
	var receiver_id = multiplayer.get_unique_id()

	var sender_resources = game_inventory.get_player_resources(sender_id)
	var receiver_resources = game_inventory.get_player_resources(receiver_id)

	# Sprawdzenie czy nadawca nadal posiada to, co oferował
	if not player_has_resources(offer_values, sender_resources):
		print("Nadawca nie ma już wymaganych surowców.")
		return

	# Sprawdzenie czy osoba akceptująca ma to, co musi oddać
	if not player_has_resources(invert_offer(offer_values), receiver_resources):
		print("Nie masz wystarczających surowców do tej wymiany.")
		return

	# Wykonanie wymiany
	for res in offer_values:
		var amount = offer_values[res]

		if amount > 0:
			# Nadawca dostaje
			game_inventory.give_resource(sender_id, res, amount)
			game_inventory.take_resource(receiver_id, res, amount)

		elif amount < 0:
			var abs_amount = abs(amount)

			# Nadawca oddaje
			game_inventory.take_resource(sender_id, res, abs_amount)
			game_inventory.give_resource(receiver_id, res, abs_amount)

	game_inventory.update_inventory()
	gui.update_gui()

	rpc("remove_trade_offer", sender_id)
	
func invert_offer(offer_values: Dictionary) -> Dictionary:
	var inverted_offer = {}

	for res in offer_values:
		inverted_offer[res] = -offer_values[res]

	return inverted_offer

func player_has_resources(offer_values: Dictionary, player_resources: Dictionary) -> bool:
	for res in offer_values:
		var amount = offer_values[res]

		# Wartość ujemna = gracz oddaje surowiec
		if amount < 0:
			if player_resources.get(res, 0) < abs(amount):
				print("Graczowi brakuje ", res, ": ", abs(amount))
				return false

	return true

func bank_has_resources(offer_values: Dictionary, bank_resources: Dictionary) -> bool:
	for res in offer_values:
		var amount = offer_values[res]

		if amount > 0:
			if bank_resources.get(res, 0) < amount:
				print("Bankowi brakuje ", res, ": ", amount)
				return false

	return true

func trade_with_bank(sender_id, offer_values):
	var player_resources = game_inventory.get_player_resources(sender_id)
	var bank_resources = game_inventory.get_player_resources(0)

	# Sprawdzenie gracza
	if not player_has_resources(offer_values, player_resources):
		print("Gracz nie ma wystarczających surowców.")
		return

	# Sprawdzenie banku
	if not bank_has_resources(offer_values, bank_resources):
		print("Bank nie ma wystarczających surowców.")
		return

	# Wykonanie wymiany
	for res in offer_values:
		var amount = offer_values[res]

		if amount > 0:
			# Bank daje graczowi
			game_inventory.take_resource(0, res, amount)
			game_inventory.give_resource(sender_id, res, amount)

		elif amount < 0:
			var abs_amount = abs(amount)

			# Gracz daje bankowi
			game_inventory.take_resource(sender_id, res, abs_amount)
			game_inventory.give_resource(0, res, abs_amount)

	game_inventory.update_inventory()
	gui.update_gui()

@rpc("any_peer", "call_local")
func remove_trade_offer(sender_id):
	var offer_container = gui.get_node("OfferContainer")

	for trade_offer in offer_container.get_children():
		if trade_offer.sender_id == sender_id:
			trade_offer.queue_free()
