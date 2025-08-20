extends Control

@onready var inventory = $"../../GameInventory"
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

@onready var dice1 = $DiceContainer/DiceButton/Dice1Sprite
@onready var dice2 = $DiceContainer/DiceButton/Dice2Sprite

var k1 = 0
var k2 = 0
var map_tiles = -1
var resource_dict = {1:"wood", 2:"iron", 3:"oil", 4:"coal", 5:"uran"}
@onready var resource_count = {"wood":wood_count, "iron":iron_count, "oil":oil_count, "coal":coal_count, "uran":uran_count}
@onready var bank_resource_count = {"wood":bank_wood_count, "iron":bank_iron_count, "oil":bank_oil_count, "coal":bank_coal_count, "uran":bank_uran_count}

func update_gui():
	print("Uruchamiam update")
	rpc("update_player_resources")
	
@rpc("any_peer", "call_local")
func update_player_resources():
	print("Gracz ", multiplayer.get_unique_id(), " robi update")
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


func _on_bank_button_toggled(toggled_on: bool) -> void:
	var bank_container_tween = create_tween()
	if toggled_on:
		bank_container_tween.tween_property(bank_container,"position",bank_container_pos ,1)
	else:
		bank_container_tween.tween_property(bank_container,"position",bank_container_pos + Vector2(110,0), 1)
