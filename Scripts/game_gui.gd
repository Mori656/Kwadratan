extends Control

@onready var inventory = $"../../GameInventory"
@onready var wood_count = $PlayerResourcesContainer/Panel/WoodCount
@onready var iron_count = $PlayerResourcesContainer/Panel/IronCount
@onready var oil_count = $PlayerResourcesContainer/Panel/OilCount
@onready var coal_count = $PlayerResourcesContainer/Panel/CoalCount
@onready var uran_count = $PlayerResourcesContainer/Panel/UranCount
@onready var resources_container = $PlayerResourcesContainer
@onready var resources_container_pos = resources_container.position

@onready var dice1 = $DiceContainer/DiceButton/Dice1Sprite
@onready var dice2 = $DiceContainer/DiceButton/Dice2Sprite

var k1 = 0
var k2 = 0
var map_tiles = -1
var resource_dict = {1:"wood", 2:"iron", 3:"oil", 4:"coal", 5:"uran"}
@onready var resource_count = {"wood":wood_count, "iron":iron_count, "oil":oil_count, "coal":coal_count, "uran":uran_count}

func update_gui():
	print("Uruchamiam update")
	rpc("update_player_resources")
	
@rpc("any_peer", "call_local")
func update_player_resources():
	print("Gracz ", multiplayer.get_unique_id(), " robi update")
	
	#Tworzenie gui surowców
	var player_resources = inventory.get_player_resources(multiplayer.get_unique_id())
	for i in resource_dict:
		resource_count[resource_dict[i]].text = str(player_resources[resource_dict[i]])

func _on_dice_button_pressed() -> void:
	k1 = randi() % 6 + 1
	k2 = randi() % 6 + 1
	
	dice1.frame = k1 - 1
	dice2.frame = k2 - 1
	
	give_resources()
	pass

func give_resources() -> void:
	map_tiles = get_parent().get_parent().get_node("Map/tiles")
	#inventory.on_dice_rolled(resource_dict[1])
	for tile in map_tiles.get_children():
		if tile.get_value() == k1 + k2:
			inventory.on_dice_rolled(resource_dict[tile.get_resource()])
			pass
		pass

func _on_hide_button_toggled(toggled_on: bool) -> void:
	var resources_container_tween = create_tween()
	if toggled_on:
		resources_container_tween.tween_property(resources_container,"position",resources_container_pos ,1)
	else:
		resources_container_tween.tween_property(resources_container,"position",resources_container_pos + Vector2(0,50), 1)
