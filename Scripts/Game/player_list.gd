extends Node2D

var players_list

# Ustawienie listy graczy host
func setup_players_list(list):
	players_list = list
	rpc("sync_players_list", players_list)
	
# Ustawienie listy graczy inni
@rpc("authority","call_local")
func sync_players_list(list):
	players_list = list
	
# Pobranie listy graczy
func get_players_list():
	return players_list
