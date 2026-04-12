extends Control

@onready var inventory = $"../../../GameInventory"
@onready var player_list_module = $"../../../PlayerList"
@onready var players_displays_container: HBoxContainer = $PlayersDisplaysContainer
@onready var player_display = preload("res://Scenes/Prefabs/player_display.tscn")

func update_players_display():
	var inventory_copy = inventory.get_inventory()
	var players = player_list_module.get_players_list()
	if !players:
		print("Lista graczy nieznana")
	else:
		for child in players_displays_container.get_children():
			players_displays_container.remove_child(child)
			
		for player_id in players:
			if player_id != multiplayer.get_unique_id():
				# nazwa gracza
				var player_name = players[player_id] 
				# ilość surowców
				var resources_count = 0
				for value in inventory_copy[player_id]["resources"].values():
					resources_count += value
				# ilość kart
				var cards_count = inventory_copy[player_id]["cards"].size()
				# Dodać wyświetlanie punktów tu!!!
				# Punkty
				# Przygotowanie displaya
				var display = player_display.instantiate()
				players_displays_container.add_child(display)
				display.setup_value(player_name,resources_count,cards_count)
