extends Node

@onready var game = get_parent()

# ========= Sprawdzanie czy można budować =========

func get_player_number(requester_id: int) -> int:
	print(requester_id)
	print(game.turn_manager.turn_order)
	return game.turn_manager.turn_order.find(requester_id) # Pobiera numer gracza na podstawie jego sieciowego ID w tablicy tur

func can_build_factory(row: int, column: int, requester_id: int) -> Dictionary:
	var player_number = get_player_number(requester_id)
	if player_number == -1:
		return {"can_build": false, "reason": "Nie znaleziono gracza w turn_order!"}
		
	# Weryfikacja tury po ID zamiast po indeksie
	var current_turn_player_id = game.turn_manager.turn_order[game.turn_manager.current_turn_index]
	if requester_id != current_turn_player_id:
		return {"can_build": false, "reason": "To nie tura tego gracza!"}

	var point = game.get_map_point(row, column)
	if not point:
		return {"can_build": false, "reason": "Nie znaleziono punktu na mapie!"}

	if not point.active:
		return {"can_build": false, "reason": "Nie możesz budować na morzu"}

	if point.upgraded_factory:
		return {"can_build": false, "reason": "Fabryka jest już maksymalnie ulepszona!"}

	var building_type = ""
	var building_name_pl = ""

	if not point.factory:
		if has_neighbor_factory(row, column):
			return {"can_build": false, "reason": "Nie można postawić – obok już jest fabryka!"}
		building_type = "factory"
		building_name_pl = "Fabrykę"
	elif point.player_owner == player_number:
		building_type = "nuclear_power_plant"
		building_name_pl = "Elektrownię Jądrową"
	else:
		return {"can_build": false, "reason": "To miejsce należy do innego gracza!"}

	if not game.game_inventory.can_afford(requester_id, building_type):
		return {"can_build": false, "reason": "Nie masz wystarczającej ilości surowców!"}

	return {
		"can_build": true,
		"building_type": building_type,
		"building_name_pl": building_name_pl,
		"reason": ""
	}

func can_build_road(road_name: String, requester_id: int) -> Dictionary:
	var player_number = get_player_number(requester_id)
	if player_number == -1:
		return {"can_build": false, "reason": "Nie znaleziono gracza w turn_order!"}

	var road = game.get_node("Map/roads").get_node_or_null(road_name)
	if not road or road.player_owner != -1:
		return {"can_build": false, "reason": "Ta droga już do kogoś należy!"}

	var p1 = road.get_node(road.point_a_path)
	var p2 = road.get_node(road.point_b_path)

	if !(p1.player_owner == player_number or p2.player_owner == player_number):
		return {"can_build": false, "reason": "Droga musi łączyć się z Twoim punktem/fabryką!"}

	if (p1.player_owner != -1 and p1.player_owner != player_number) or (p2.player_owner != -1 and p2.player_owner != player_number):
		return {"can_build": false, "reason": "Punkt przynależy do innego gracza!"}

	if not game.game_inventory.can_afford(requester_id, "road"):
		return {"can_build": false, "reason": "Nie masz wystarczającej ilości surowców na drogę!"}

	return {
		"can_build": true,
		"building_type": "road",
		"building_name_pl": "Drogę",
		"reason": ""
	}

func has_neighbor_factory(row: int, column: int) -> bool:
	for p in game.get_node("Map/points").get_children():
		var same_row = (p.row == row and abs(p.column - column) == 1)
		var same_col = (p.column == column and abs(p.row - row) == 1)
		if (same_row or same_col) and p.factory:
			return true
	return false

# ===== Serwer - budowanie i zabieranie surowców ======

@rpc("any_peer", "call_local", "reliable")
func request_place_factory(row: int, column: int):
	if not multiplayer.is_server(): return
	
	var requester_id = multiplayer.get_remote_sender_id()
	if requester_id == 0: requester_id = multiplayer.get_unique_id()

	# Weryfikacja tury po ID zamiast po indeksie
	var current_turn_player_id = game.turn_manager.turn_order[game.turn_manager.current_turn_index]
	if requester_id != current_turn_player_id:
		print("To nie tura tego gracza!")
		return

	var check = can_build_factory(row, column, requester_id)
	if not check.can_build:
		print("Serwer odrzucił budowę: ", check.reason)
		return

	var player_number = get_player_number(requester_id)
	var building_type = check.building_type
	var cost = game.game_inventory.COSTS[building_type]
	var is_upgrade = (building_type == "nuclear_power_plant")

	# Aktualizacja mapy i zabranie zasobów
	game.update_map_point.rpc(row, column, player_number, is_upgrade)

	for res_type in cost:
		game.game_inventory.take_resource(requester_id, res_type, cost[res_type])

	game.game_inventory.update_inventory()

@rpc("any_peer", "call_local", "reliable")
func request_place_road(road_name: String):
	if not multiplayer.is_server(): return

	var requester_id = multiplayer.get_remote_sender_id()
	if requester_id == 0: requester_id = multiplayer.get_unique_id()

	# Weryfikacja tury po ID zamiast po indeksie
	var current_turn_player_id = game.turn_manager.turn_order[game.turn_manager.current_turn_index]
	if requester_id != current_turn_player_id:
		print("To nie tura tego gracza!")
		return

	var check = can_build_road(road_name, requester_id)
	if not check.can_build:
		print("Serwer odrzucił budowę drogi: ", check.reason)
		return

	var player_number = get_player_number(requester_id)
	var cost = game.game_inventory.COSTS["road"]
	for res_type in cost:
		game.game_inventory.take_resource(requester_id, res_type, cost[res_type])

	game.game_inventory.update_inventory()
	game.update_map_road.rpc(road_name, player_number)
