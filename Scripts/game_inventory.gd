extends Node2D

var resources = {0:{"wood":25, "iron":25, "oil":25, "coal":25, "uran":25}}
@onready var gui = $"../CanvasLayer/GUI"

func setup_player_inventory(id):
	var player_resources = {"wood":0, "iron":0, "oil":0, "coal":0, "uran":0}
	resources[id] = player_resources
	rpc("update_resource_count",resources)

func on_dice_rolled(res):
	print("\n\nGracz ", multiplayer.get_unique_id(), " rzucił kością!")
	rpc_id(multiplayer.get_unique_id(),"give_resource_to_players_by_dice",res)

@rpc("any_peer", "call_local")
func give_resource_to_players_by_dice(res):
	print("Przydzialanie surowców")
	for player in resources:
		print("(Przed) Gracz", player, " ma ", resources[player])
	if take_resource(0, res, 1): # zabieramy 1 surowiec z banku
		give_resource(multiplayer.get_unique_id(),res,1)
		print("Gracz ", multiplayer.get_unique_id(), " otrzymał ", res) ## print kto co dostał
	else:
		print("Bank nie ma wystarczającej ilości zasobu: ", res)
	for player in resources:
		print("Gracz", player, " ma ", resources[player])
	rpc("update_resource_count", resources)
	gui.update_gui()
	
@rpc("any_peer","call_local")
func update_resource_count(new_resources: Dictionary):
	resources = new_resources
		
func take_resource(id: int, res: String, count: int) -> bool:
	if resources[id][res] >= count:
		resources[id][res] -= count
		return true
	return false
	
func give_resource(id: int, res: String, count: int):
	resources[id][res] += count
	
func get_player_resources(id: int):
	if resources.has(id):
		return resources[id]
	else:
		push_error("Player ID %d does not exist in resources." % id)
		return null
	

	
