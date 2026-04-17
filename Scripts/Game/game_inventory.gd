extends Node2D

@onready var gui = $"../CanvasLayer/GUI"

var inventory = {0:{"resources":{"wood":25, "iron":25, "oil":25, "coal":25, "uran":25},"cards":[]}}

var cards_in_deck = 10

const COSTS = {
	"factory": {"wood": 1, "iron": 1, "coal": 1},
	"nuclear_power_plant": {"iron": 3, "uran": 3},
	"road": {"wood": 1, "oil": 1}
}

func can_afford(player_id: int, building_type: String) -> bool:
	var cost = COSTS[building_type]
	for res in cost:
		if inventory[player_id]["resources"][res] < cost[res]:
			return false
	return true


### Inventory ###
		
func setup_player_inventory(id):
	var player_inventory = {"resources":{"wood":10, "iron":10, "oil":10, "coal":10, "uran":10},"cards":[]}
	inventory[id] = player_inventory
	rpc("update_bank_inventory",inventory)

func update_inventory(new_inventory: Dictionary = inventory):
	rpc("update_bank_inventory",new_inventory)

@rpc("any_peer","call_local")
func update_bank_inventory(new_inventory: Dictionary):
	inventory = new_inventory
	gui.update_player_resources()#update gui po zmianach

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
		push_error("Nie znaleziono surowców gracza od ID %d" % id)
		return {"wood": 0, "iron": 0, "oil": 0, "coal": 0, "uran": 0} #zapobiegam błędowi inicjalizacji :/ 

func get_inventory():
	return inventory
	
