extends Node2D

@onready var player_list_ui = $VBoxContainer/PlayerList
@onready var map_label = $VBoxContainer/HBoxContainer/SelectedMap
@onready var start_button = $VBoxContainer/HBoxContainer/StartButton

# Używamy słownika  do przechowywania graczy {id: nazwa}
var players: Dictionary = {}
var selected_map_path = ""

func _ready():
	$MapSelector.hide()
	$MapSelector.connect("map_selected", Callable(self, "_on_map_selected"))
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# Jeśli host
	if CoopHandler.is_host:
		print("You are the host")
		start_button.show()
		# Host dodaje siebie. Jego ID to zawsze 1.
		players[1] = CoopHandler.player_name
		update_player_list(players)
# Jeśli jesteś klientem
	else:
		print("You are the client")
		start_button.hide()
# Klient wysyła prośbę o rejestrację do hosta
		multiplayer.connected_to_server.connect(_on_connected_to_server)

# gdy klient nawiąże połączenie automatycznie się wywoła:
func _on_connected_to_server():
	print("Successfully connected to the server!")
	# Dopiero teraz, gdy mamy pewność połączenia, wysyłamy RPC do hosta.
	rpc_id(1, "register_player_on_host", CoopHandler.player_name)

func _on_peer_disconnected(peer_id: int):
# Obsługa hosta
	if not CoopHandler.is_host:
		return
# Sprawdź, czy gracz faktycznie był na liście i usuń go
	if players.has(peer_id):
		var disconnected_player_name = players[peer_id]
		players.erase(peer_id)
		print("Player disconnected: " + disconnected_player_name)
# Roześlij wszystkim nową, zaktualizowaną listę graczy
		rpc("update_player_list", players)

func _on_select_map_button_pressed():
	if CoopHandler.is_host:
		$MapSelector.popup_centered()

func _on_map_selected(path: String):
	selected_map_path = path
	map_label.text = path.get_file().get_basename()
	$MapSelector.hide()
	# Host informuje wszystkich o wybranej mapie
	rpc("sync_map_selection", path)

func _on_start_button_pressed() -> void:
	if CoopHandler.is_host and selected_map_path != "":
		# host wysyła sygnał startu gry - można tu dodać ready sprawdzanie
		rpc("start_game", selected_map_path)

func _on_back_button_pressed():
	if multiplayer.get_multiplayer_peer(): #jak połączony jeszcze to odłącz
		multiplayer.get_multiplayer_peer().close()
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

# TA FUNKCJA WYKONYWANA JEST TYLKO NA HOŚCIE, GDY KLIENT CHCE DOŁĄCZYĆ
@rpc("any_peer")
func register_player_on_host(player_name: String):
	# Tylko host
	if not CoopHandler.is_host:
		return
		
	print("Host received registration from: " + player_name)
	# Pobieramy ID gracza który wysłał ten RPC
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = player_name
	print("Host registered player: " + player_name + " with ID: " + str(new_player_id))
	# Po dodaniu gracza, host wysyła zaktualizowaną, pełną listę do WSZYSTKICH
	rpc("update_player_list", players)

# TA FUNKCJA WYKONYWANA JEST NA WSZYSTKICH MASZYNACH (HOST I KLIENCI), GDY HOST ROZSYŁA LISTĘ
@rpc("any_peer", "call_local")
func update_player_list(new_player_list: Dictionary):
	self.players = new_player_list #lista wziąta od hosta
	for child in player_list_ui.get_children():
		child.queue_free() #wyczyść listę
# dodawanie labeli na podstawie listy, dodajemy dopisek (dla swojego nicku)
	for peer_id in players:
		var player_name = players[peer_id]
		var label = Label.new()
		var label_text = player_name
		if peer_id == multiplayer.get_unique_id():
			label_text += " (You)"
		label.text = label_text
		player_list_ui.add_child(label)

@rpc("any_peer", "call_local")
func sync_map_selection(path: String):
	map_label.text = path.get_file().get_basename()

@rpc("any_peer", "call_local")
func start_game(map_path: String):
	CoopHandler.selected_map = map_path 
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
