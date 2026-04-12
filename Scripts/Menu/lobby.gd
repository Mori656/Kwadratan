extends Node2D

@onready var player_list_ui = $PlayersContainer/MarginContainer/PlayerList
@onready var map_label = $OptionsContainer/VBoxContainer/HBoxContainer/SelectedMapLabel
@onready var start_button = $OptionsContainer/VBoxContainer/StartButton

# Używamy słownika  do przechowywania graczy {id: nazwa}
var players: Dictionary = {}
var selected_map_path = ""
var logs: Array = []

func _ready():
	$MapSelector.hide()
	$MapSelector.connect("map_selected", Callable(self, "_on_map_selected"))
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# Jeśli host
	if CoopHandler.is_host:
		add_log_entry("Lobby created.")
		start_button.show()
		# Host dodaje siebie. Jego ID to zawsze 1.
		players[1] = CoopHandler.player_name
		update_player_list(players)
# Jeśli jesteś klientem
	else:
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
		add_log_entry("Player disconnected: " + disconnected_player_name)
# Roześlij wszystkim nową, zaktualizowaną listę graczy
		rpc("update_player_list", players)

func _on_select_map_button_pressed():
	if CoopHandler.is_host:
		$MapSelector.popup_centered()

func _on_map_selected(path: String):
	selected_map_path = path
	map_label.text = "selected map: " + path.get_file().get_basename() 
	$MapSelector.hide()
	add_log_entry("Changed map to: " + path.get_file().get_basename())
	# Host informuje wszystkich o wybranej mapie
	rpc("sync_map_selection", path)

func _on_start_button_pressed() -> void:
	if CoopHandler.is_host and selected_map_path != "":
		 # ZAPISZ LISTĘ GRACZY DO SINGLETONA
		CoopHandler.players_in_game = players
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
	#print("Host registered player: " + player_name + " with ID: " + str(new_player_id))
	add_log_entry("Host registered player: " + player_name + " with ID: " + str(new_player_id))
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
		label.theme = load("res://Assets/Styles/player_label_style.tres")
		player_list_ui.add_child(label)

@rpc("any_peer", "call_local")
func sync_map_selection(path: String):
	map_label.text = "Selected map: " + path.get_file().get_basename() 


@rpc("any_peer", "call_local")
func start_game(map_path: String):
	CoopHandler.selected_map = map_path 
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func add_log_entry(message: String): #logi dodawane przez hosta
	if not CoopHandler.is_host:
		return
	var timestamp = Time.get_time_string_from_system()
	var full_message = "[%s] %s" % [timestamp, message]
	logs.append(full_message)
	# Synchronizacja logów z wszystkimi
	rpc("sync_logs", logs)
	
@rpc("any_peer", "call_local")
func sync_logs(new_logs: Array):
	logs = new_logs.duplicate()
	var logs_container = $LogsContainer/Logs
	for child in logs_container.get_children():
		child.queue_free()

	for log_entry in logs:
		var label = Label.new()
		label.text = log_entry
		label.theme = load("res://Assets/Styles/log_label_style.tres") #TO do naprawić
		logs_container.add_child(label)

	# Auto-scroll w dół (jeśli masz ScrollContainer)
	var scroll = $LogsContainer
	if scroll is ScrollContainer:
		await get_tree().process_frame
		scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
