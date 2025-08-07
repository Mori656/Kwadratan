extends Node2D

@onready var player_list_container = $Players/VBoxContainer
@onready var dice_button = $GUI/DiceContainer/DiceButton

var turn_order: Array = [] #na podstawie listy graczy
var current_turn_index := 0

func _ready():
	dice_button.pressed.connect(_on_dicebutton_pressed) 
	if multiplayer.is_server():
		#wczytujemy mapę i wysyłamy listę graczy 
		load_map.rpc(CoopHandler.selected_map)
		send_players_list_to_clients.rpc(CoopHandler.players_in_game)
		
		# Serwer ustala kolejność tury
		turn_order = CoopHandler.players_in_game.keys()
		current_turn_index = 0
		update_turn.rpc(turn_order[current_turn_index])
		
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if multiplayer.get_multiplayer_peer():
			multiplayer.get_multiplayer_peer().close() #rozłączenie
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
		
# mapa na hoscie i komputerach
@rpc("any_peer", "call_local", "reliable")
func load_map(map_path: String):
# usuwam placeholder
	for child in $Map.get_children():
		child.queue_free()
	# wybrana mapa
	var map_scene = load(map_path)
	var map_instance = map_scene.instantiate()

	$Map.add_child(map_instance)
	print("Mapa '%s' została pomyślnie załadowana." % map_path)

# aktualizowana tura wszędzie
@rpc("any_peer", "call_local", "reliable")
func update_turn(peer_id: int):
	var my_id = multiplayer.get_unique_id()
	var is_my_turn = my_id == peer_id
	
	dice_button.disabled = not is_my_turn
	if is_my_turn:
		print("Tura gracza", peer_id)
	else:
		print("Tura gracza", peer_id)

# kliknięcie przycisku przez gracza z turą
func _on_dicebutton_pressed():
	if dice_button.disabled:
		return # nie masz tury!

	print("Kliknięto przycisk – rzut kością!")
	request_end_turn.rpc() # wywołujemy requesta końca tury

# tylko serwer może zmienić turę
# Klient może ją wywołać (żeby host mógł zmienić)
@rpc("any_peer", "call_local", "reliable")
func request_end_turn():
	if multiplayer.is_server():
		end_turn() # wywołanie lokalne, bez RPC

# Tylko serwer może wykonać (wywołanie tylko z request)
func end_turn():
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0

	var next_peer_id = turn_order[current_turn_index]
	update_turn.rpc(next_peer_id)
	
@rpc("any_peer", "call_local", "reliable")
func send_players_list_to_clients(players: Dictionary):
	show_all_players(players)

func show_all_players(players: Dictionary):
	if players.is_empty():
		print("Błąd: Brak graczy do wyświetlenia!")
		return

	for player_id in players:
		var player_name = players[player_id]
		var label = Label.new()
		if player_id == multiplayer.get_unique_id():
			label.text = player_name + " (You)"
		else:
			label.text = player_name
		player_list_container.add_child(label)
