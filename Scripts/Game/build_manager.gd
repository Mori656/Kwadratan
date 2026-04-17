extends Node

@onready var game = get_parent()
@onready var game_inventory: Node2D = $"../GameInventory"

@rpc("any_peer", "call_local", "reliable")
func request_place_factory(row: int, column: int):
	if not multiplayer.is_server(): return
	
	var requester_id = multiplayer.get_remote_sender_id()
	if requester_id == 0: requester_id = multiplayer.get_unique_id()

	var player_number = game.turn_manager.current_turn_index 
	
	if requester_id != game.turn_manager.turn_order[game.turn_manager.current_turn_index]:
		print("to nie tura tego gracza!")
		return
		
	var cost = 0
	for point in game.get_node("Map/points").get_children():
		if point.row != row or point.column != column:
			continue
			
		if not point.active:
			print("Nie możesz tu budować na morzu :)")
			return
				
		if not point.factory:
			if has_neighbor_factory(row, column):
				print("Nie można postawić – obok już jest fabryka!")
				return
			if not game.game_inventory.can_afford(requester_id, "factory"):
				print("Nie masz wystarczającej ilości surowców na fabrykę!")
				return
			cost = game.game_inventory.COSTS["factory"]
			game.update_map_point.rpc(row, column, player_number, false)
				
		elif point.player_owner == player_number:
			if not game.game_inventory.can_afford(requester_id, "nuclear_power_plant"):
				print("Nie masz wystarczającej ilości surowców na elektrownie!")
				return
			cost = game.game_inventory.COSTS["nuclear_power_plant"]
			game.update_map_point.rpc(row, column, player_number, true)
			
		for res_type in cost:
			var amount = cost[res_type]
			game.game_inventory.take_resource(requester_id, res_type, amount)
				
	game_inventory.rpc("update_bank_inventory", game_inventory.inventory)

@rpc("any_peer", "call_local", "reliable")
func request_place_road(road_name: String):
	if not multiplayer.is_server(): return
		
	var requester_id = multiplayer.get_remote_sender_id()
	if requester_id == 0: requester_id = multiplayer.get_unique_id()
		
	var player_number = game.turn_manager.current_turn_index
	
	if requester_id != game.turn_manager.turn_order[game.turn_manager.current_turn_index]:
		return
	
	var road = game.get_node("Map/roads").get_node_or_null(road_name)
		
	if !road or road.player_owner != -1:
		print("Nie możesz tu budować! Ta droga już do kogoś należy.")
		return 
	
	var p1 = road.get_node(road.point_a_path)
	var p2 = road.get_node(road.point_b_path)
			
	if !(p1.player_owner == player_number or p2.player_owner == player_number):
		print("Nie możesz tu budować! Droga musi łączyć się z Twoim punktem/fabryką.")
		return
		
	if (p1.player_owner != -1 and p1.player_owner != player_number) or (p2.player_owner != -1 and p2.player_owner != player_number):
		print("Nie możesz tu budować! Punkt przynależy do innego gracza")
		return

	if not game.game_inventory.can_afford(requester_id, "road"):
		print("Nie masz wystarczającej ilości surowców na drogę!")
		return
				
	var cost = game.game_inventory.COSTS["road"]
	for res_type in cost:
		var amount = cost[res_type]
		game.game_inventory.take_resource(requester_id, res_type, amount)
					
	game.game_inventory.rpc("update_bank_inventory", game.game_inventory.inventory)
	game.update_map_road.rpc(road_name, player_number)

func has_neighbor_factory(row: int, column: int) -> bool:
	for p in game.get_node("Map/points").get_children():
		var same_row = (p.row == row and abs(p.column - column) == 1)
		var same_col = (p.column == column and abs(p.row - row) == 1)
		if (same_row or same_col) and p.factory:
			return true
	return false
