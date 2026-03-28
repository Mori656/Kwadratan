extends Node2D

@onready var player_list_container = $CanvasLayer/GUI/Players/VBoxContainer
@onready var dice_button = $CanvasLayer/GUI/DiceContainer/DiceButton
@onready var gui = $CanvasLayer/GUI
@onready var game_inventory = $GameInventory

var turn_order: Array = [] #na podstawie listy graczy
var current_turn_index := 0


func _ready():
	dice_button.pressed.connect(_on_dicebutton_pressed) 
	if multiplayer.is_server():
		#wczytujemy mapę i wysyłamy listę graczy 
		load_map.rpc(CoopHandler.selected_map)
		send_players_list_to_clients.rpc(CoopHandler.players_in_game)
		
		
		for player_id in CoopHandler.players_in_game:
			print(player_id)
			game_inventory.setup_player_inventory(player_id)
		
		#Przygotowanie kart w banku
		game_inventory.setup_deck()
		
		gui.update_gui()
		
		# Serwer ustala kolejność tury
		turn_order = CoopHandler.players_in_game.keys()
		current_turn_index = 0
		update_turn.rpc(turn_order[current_turn_index])
		
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if multiplayer.get_multiplayer_peer():
			multiplayer.get_multiplayer_peer().close() #rozłączenie
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
		
# WCZYTYWANIE WSPÓLNEJ MAPY
@rpc("any_peer", "call_local", "reliable")
func load_map(map_path: String):
	var map_scene = load(map_path)
	var map_instance = map_scene.instantiate()
	map_instance.name = "Map"
	$".".add_child(map_instance)
	print("Mapa '%s' została pomyślnie załadowana." % map_path)
	
	# Łączenie tile, pointów i dróg (obsługa kliknięć)
	for tile in map_instance.get_node("tiles").get_children():
		tile.connect("input_event", Callable(self, "_on_tile_clicked").bind(tile))

	for point in $Map.get_node("points").get_children():
		point.connect("input_event", Callable(self, "_on_point_clicked").bind(point))
		point.update_visual_start_game() #zmiana wyglądu na kolej
	
	for road in map_instance.get_node("roads").get_children():
		road.connect("input_event", Callable(self, "_on_road_clicked").bind(road))
		
# AKTUALIZOWANIE TURY WSZĘDZIE
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

# REQUEST KLIENTA KOŃCA TURY - OBSŁUGA PRZEZ HOSTA
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

#WSPÓLNA LISTA GRACZY	
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

#STAWIANIE BANDYTY - TODO#
func _on_tile_clicked(_viewport, event, _shape_idx, tile):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Lewy klik:", tile.name)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Prawy klik:", tile.name)

#CAŁA FUNKCJONALNOŚĆ STAWIANIE I OBSŁUGA FABRYK#

func _on_point_clicked(_viewport, event, _shape_idx, point):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		request_place_factory.rpc_id(1, point.row, point.column)

func _on_road_clicked(_viewport, event, _shape_idx, road):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Klikam drogę: ", road.name)
		request_place_road.rpc_id(1, road.name) # Wysyłamy prośbę do serwera, nazwa obiektu jako ID
		
@rpc("any_peer", "call_local", "reliable")
func request_place_factory(row: int, column: int):
	# Upewniamy się, że tylko host wykonuje tę logikę
	if not multiplayer.is_server():
		return
	var requester_id = multiplayer.get_remote_sender_id()
	# jeśli wywołane lokalnie na serwerze, to przypisz jego własne ID
	if requester_id == 0:
		requester_id = multiplayer.get_unique_id()

	var player_number = current_turn_index #numer gracza  - do kolorów
	# Sprawdzamy, czy prośbę wysłał gracz, którego jest tura
	if requester_id == turn_order[current_turn_index]:
		### to ma się wykonać kiedy zaakceptuje host
		for point in $Map.get_node("points").get_children():
			if point.row == row and point.column == column:
				
				# Czy punkt nie jest na morzu - stan z kreatora
				if not point.active:
					print("Nie możesz tu budować na morzu " + ':)' )
					return
				
				if not point.factory: # Jeśli można zbudować
					# sprawdź sąsiadów (odległość 1)
					if has_neighbor_factory(row, column):
						print("Nie można postawić – obok już jest fabryka!")
						return
				# jeśli brak sąsiadów -> buduj
					update_map_point.rpc(row, column, player_number, false) #zbuduj
				elif point.player_owner == player_number: #jak twoje to możesz ulepszyc:
					update_map_point.rpc(row, column, player_number, true) # true = ulepsz
	else:
		print("to nie jest tura tego gracza")
		return

@rpc("any_peer", "call_local", "reliable")
func request_place_road(road_name: String):
	if not multiplayer.is_server():
		return
		
	var requester_id = multiplayer.get_remote_sender_id()
	if requester_id == 0:
		requester_id = multiplayer.get_unique_id()
		
	var player_number = current_turn_index
	
	if requester_id == turn_order[current_turn_index]:
		var road = $Map.get_node("roads").get_node_or_null(road_name)
		
		if road and road.player_owner == -1:
			# Punkty końcowe drogi
			var p1 = road.get_node(road.point_a_path)
			var p2 = road.get_node(road.point_b_path)
			
			# SPRAWDZENIE Czy którykolwiek punkt należy do gracza
			if p1.player_owner == player_number or p2.player_owner == player_number:
				#sprawdzenie czy punkt przynależy do innego gracza.
				if (p1.player_owner != -1 and p1.player_owner != player_number) or (p2.player_owner != -1 and p2.player_owner != player_number):
					print("Nie możesz tu budować! Punkt przynależy do innego gracza")
				else:
					update_map_road.rpc(road_name, player_number)
			else:
				print("Nie możesz tu budować! Droga musi łączyć się z Twoim punktem/fabryką.")

#WSZYSCY (wykonują polecenie od hosta - aktualizacja planszy
@rpc("any_peer", "call_local", "reliable")
func update_map_point(row: int, column: int, owner_player_number: int, should_upgrade: bool):
	# Każdy gracz update na mapce
	for point in $Map.get_node("points").get_children():
		if point.row == row and point.column == column:
			point.set_point_owner(owner_player_number)
			if not should_upgrade:
				point.place_factory()
			else:
				point.upgrade_factory()

@rpc("any_peer", "call_local", "reliable")
func update_map_road(road_name: String, owner_player_number: int):
	var road = $Map.get_node("roads").get_node_or_null(road_name)
	
	if road:
		print("Nowy właściciel drogi i punktów: ", owner_player_number)
		if(road.player_owner != owner_player_number):
			road.player_owner = owner_player_number
			road.update_visual_game()
		
		
		var p1 = road.get_node(road.point_a_path)
		var p2 = road.get_node(road.point_b_path)
		
		# przypisujemy punkty na końcach drogi do gracza stawiającego drogę
		p1.set_point_owner(owner_player_number)
		p2.set_point_owner(owner_player_number)
		p1.update_visual_game()
		p2.update_visual_game()



func has_neighbor_factory(row: int, column: int) -> bool:
	for p in $Map.get_node("points").get_children():
		var same_row = (p.row == row and abs(p.column - column) == 1) # sąsiad lewo prawo - ten sam wiersz
		var same_col = (p.column == column and abs(p.row - row) == 1) # sąsiad góra dół ta sama kolumna

		if (same_row or same_col) and p.factory: #jeśli sąsiad true
			return true
	return false
