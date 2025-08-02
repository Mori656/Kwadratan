extends Node2D

var resources = {"wood":25, "brick":25, "sheep":25, "grain":25, "stone":25}

func on_dice_rolled(res):
	if multiplayer.is_server():
		print("To jest serwer — rozdajemy lokalnie")
		give_resource_to_players_by_dice(res)
	else:
		print("To jest klient — wysyłamy do serwera rpc_id(1)")
		rpc_id(1, "give_resource_to_players_by_dice", res)

@rpc("any_peer")
func give_resource_to_players_by_dice(res):
	print("Przydzialanie surowców")
	for player in get_tree().get_nodes_in_group("players"):
		if take_resource(res, 1): # zabieramy 1 surowiec z banku
			player.rpc("give_resource_to_player", res, 1)
		else:
			print("Bank nie ma wystarczającej ilości zasobu: ", res)
	rpc("update_resource_count", resources)
		
func take_resource(res: String, count: int) -> bool:
	if resources.has(res) and resources[res] >= count:
		resources[res] -= count
		return true
	return false
	
@rpc("call_remote")
func update_resource_count(new_resources: Dictionary):
	resources = new_resources
	
