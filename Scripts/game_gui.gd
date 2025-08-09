extends Control

var k1 = 0
var k2 = 0
var map_tiles = -1
var resource_dict = {1:"wood", 2:"brick", 3:"sheep", 4:"grain", 5:"stone"}

@onready var inventory = $"../../GameInventory"
@onready var player_resources_container = $PlayerResourceContainer
	
func update_gui():
	print("Uruchamiam update")
	rpc("update_player_resources")
	
@rpc("any_peer", "call_local")
func update_player_resources():
	print("Gracz ", multiplayer.get_unique_id(), " robi update")
	#Czyszczenie gui surowców
	for child in player_resources_container.get_children():
		child.queue_free()
	
	#Tworzenie gui surowców
	var player_resources = inventory.get_player_resources(multiplayer.get_unique_id())
	for i in resource_dict:
		var box = VBoxContainer.new()
		var title = Label.new()
		var count = Label.new()
		title.text = resource_dict[i]
		count.text = str(player_resources[resource_dict[i]])
		box.add_child(title)
		box.add_child(count)
		player_resources_container.add_child(box)

func _on_button_pressed() -> void:
	k1 = randi() % 6 + 1
	k2 = randi() % 6 + 1
	
	print("Kostka 1:", k1)
	print("Kostka 2:", k2)
	
	give_resources()
	pass

func give_resources() -> void:
	map_tiles = get_parent().get_parent().get_node("Map/Main/tiles")
	#inventory.on_dice_rolled(resource_dict[1])
	for tile in map_tiles.get_children():
		if tile.get_value() == k1 + k2:
			inventory.on_dice_rolled(resource_dict[tile.get_resource()])
			pass
		pass
