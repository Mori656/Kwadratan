extends Node

const IP_ADRESS: String = "localhost"
const PORT: int = 42069

var peer: ENetMultiplayerPeer
var is_host := false
var selected_map: String = ""
var player_name: String = "Player" + str(randi() % 1000) #później wybór nazwy
var players_in_game: Dictionary = {}

func start_server(players = 4) -> void:
	is_host = true
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, players)
	multiplayer.multiplayer_peer = peer
	
func start_client() -> void:
	is_host = false
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADRESS, PORT)
	multiplayer.multiplayer_peer = peer
