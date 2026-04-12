extends Control

@onready var inventory = $"../../GameInventory"
@onready var cards_deck = $"../../CardsDeck"
@onready var wood_count = $PlayerResourcesContainer/Panel/WoodCount
@onready var iron_count = $PlayerResourcesContainer/Panel/IronCount
@onready var oil_count = $PlayerResourcesContainer/Panel/OilCount
@onready var coal_count = $PlayerResourcesContainer/Panel/CoalCount
@onready var uran_count = $PlayerResourcesContainer/Panel/UranCount

@onready var bank_wood_count = $BankResourceContainer/Panel/WoodCount
@onready var bank_iron_count = $BankResourceContainer/Panel/IronCount
@onready var bank_oil_count = $BankResourceContainer/Panel/OilCount
@onready var bank_coal_count = $BankResourceContainer/Panel/CoalCount
@onready var bank_uran_count = $BankResourceContainer/Panel/UranCount

@onready var resources_container = $PlayerResourcesContainer
@onready var resources_container_pos = resources_container.position

@onready var bank_container = $BankResourceContainer
@onready var bank_container_pos = bank_container.position

@onready var cards_container = $CardsContainer

@onready var dice1 = $DiceContainer/DiceButton/Dice1Sprite
@onready var dice2 = $DiceContainer/DiceButton/Dice2Sprite

@onready var players_displays: Control = $PlayersDisplays
@onready var dice: Node2D = $"../../Dice"

var k1 = 0
var k2 = 0
var map_tiles = -1
var resource_dict = {1:"wood", 2:"iron", 3:"oil", 4:"coal", 5:"uran"}
@onready var resource_count = {"wood":wood_count, "iron":iron_count, "oil":oil_count, "coal":coal_count, "uran":uran_count}
@onready var bank_resource_count = {"wood":bank_wood_count, "iron":bank_iron_count, "oil":bank_oil_count, "coal":bank_coal_count, "uran":bank_uran_count}

@onready var turn_order = CoopHandler.players_in_game.keys() #kolejnośc graczy

func update_gui():
	print("Uruchamiam update")
	rpc("update_player_resources")
	rpc("update_player_cards")
	rpc("update_players_display")

@rpc("any_peer", "call_local")
func update_player_cards():
	cards_container.update_player_cards()

@rpc("any_peer", "call_local")
func update_players_display():
	players_displays.update_players_display()
	
@rpc("any_peer", "call_local")
func update_player_resources():
	var player_resources = inventory.get_player_resources(multiplayer.get_unique_id())
	var bank_resources = inventory.get_player_resources(0)
	for i in resource_dict:
		resource_count[resource_dict[i]].text = str(player_resources[resource_dict[i]])
		bank_resource_count[resource_dict[i]].text = str(bank_resources[resource_dict[i]])

func _on_dice_button_pressed() -> void:
	k1 = randi() % 6 + 1
	k2 = randi() % 6 + 1
	
	dice1.frame = k1 - 1
	dice2.frame = k2 - 1
	
	#żądanie przydziału zasobów
	rpc_id(1, "give_resources")
	pass


@rpc("any_peer", "call_local")
func give_resources() -> void:
 
	if not multiplayer.is_server():
		return
	var dice_sum = k1 + k2

	var map_points = get_parent().get_parent().get_node("Map/points").get_children()

	for point in map_points:
		# sprawdzamy czy jest fabryka kogoś
		if point.factory and point.player_owner != -1:
			# Pobieramy ID gracza który posiada punkt
			var player_peer_id = turn_order[point.player_owner]
			#Sprawdzamy wszystkie kafelki sąsiadujące z tym punktem
			for tile_coords in point.neighboring_tiles:
				var tile = get_tile_by_coords(tile_coords.y, tile_coords.x)
				
				if tile and tile.active and tile.get_value() == dice_sum:  #kafelek istnieje, jest lądem i value się zgadza
					var amount = 2 if point.upgraded_factory else 1 #mnożnik dla upgrade
					var res_name = resource_dict[tile.get_resource()]
					
					dice.give_resource_to_players_by_dice(res_name, player_peer_id, amount)#rozdaj surowce

# Funkcja pomocnicza -> z row i column na obiekt
func get_tile_by_coords(r: int, c: int):
	# Pobieramy listę wszystkich kafelków za każdym razem
	var tiles_list = get_parent().get_parent().get_node("Map/tiles").get_children()
	for tile in tiles_list:
		if tile.row == r and tile.column == c:
			return tile    
	return null


func _on_hide_button_toggled(toggled_on: bool) -> void:
	var resources_container_tween = create_tween()
	if toggled_on:
		resources_container_tween.tween_property(resources_container,"position",resources_container_pos ,1)
	else:
		resources_container_tween.tween_property(resources_container,"position",resources_container_pos + Vector2(0,50), 1)

func _on_bank_button_toggled(toggled_on: bool) -> void:
	var bank_container_tween = create_tween()
	if toggled_on:
		bank_container_tween.tween_property(bank_container,"position",bank_container_pos ,1)
	else:
		bank_container_tween.tween_property(bank_container,"position",bank_container_pos + Vector2(110,0), 1)

func _on_draw_card_button_button_up() -> void:
	cards_deck.on_card_draw()
	pass # Replace with function body.
	
