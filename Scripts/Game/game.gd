extends Node2D

@onready var turn_manager = $TurnManager
@onready var build_manager = $BuildManager
@onready var player_list_container = $CanvasLayer/GUI/Players/VBoxContainer
@onready var dice_button = $CanvasLayer/GUI/DiceContainer/DiceButton
@onready var gui = $CanvasLayer/GUI
@onready var game_inventory = $GameInventory
@onready var player_list: Node2D = $PlayerList
@onready var cards_deck: Node2D = $CardsDeck
@onready var dialog_manager = $DialogManager

var turn_order: Array = [] # na podstawie listy graczy
var current_turn_index := 0

func _ready():
	dice_button.pressed.connect(_on_dicebutton_pressed)
	 
	if multiplayer.is_server():
		load_map.rpc(CoopHandler.selected_map)
		send_players_list_to_clients.rpc(CoopHandler.players_in_game)
		
		for player_id in CoopHandler.players_in_game:
			game_inventory.setup_player_inventory(player_id)

		player_list.setup_players_list(CoopHandler.players_in_game)    
		cards_deck.setup_deck()
		gui.update_gui()
		
		# RPC, ABY WSZYSCY KLIENCI WIEDZIELI KTO JEST W JAKIEJ KOLEJNOŚCI:
		turn_manager.sync_turn_order.rpc(CoopHandler.players_in_game.keys())
		
		turn_manager.current_turn_index = 0
		turn_manager.update_turn.rpc(turn_manager.turn_order[turn_manager.current_turn_index])

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if multiplayer.get_multiplayer_peer():
			multiplayer.get_multiplayer_peer().close()
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

# --- WCZYTYWANIE MAPY I ŁĄCZENIE SYGNAŁÓW ---
@rpc("any_peer", "call_local", "reliable")
func load_map(map_path: String):
	var map_scene = load(map_path)
	var map_instance = map_scene.instantiate()
	map_instance.name = "Map"
	add_child(map_instance)
	print("Mapa '%s' została pomyślnie załadowana." % map_path)
	
	for tile in map_instance.get_node("tiles").get_children():
		tile.connect("input_event", Callable(self, "_on_tile_clicked").bind(tile))

	for point in map_instance.get_node("points").get_children():
		point.connect("input_event", Callable(self, "_on_point_clicked").bind(point))
		point.update_visual_start_game()
	
	for road in map_instance.get_node("roads").get_children():
		road.connect("input_event", Callable(self, "_on_road_clicked").bind(road))

# --- OBSŁUGA KLIKNIĘĆ ---

func _on_dicebutton_pressed():
	if dice_button.disabled:
		return
	print("Kliknięto przycisk – rzut kością!")
	turn_manager.request_end_turn.rpc_id(1)

func _on_point_clicked(_viewport, event, _shape_idx, point):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var my_id = multiplayer.get_unique_id()
		var info = build_manager.can_build_factory(point.row, point.column, my_id)

		if not info.can_build:
			print(info.reason)
			return

		var action_data = {
			"type": info.building_type,
			"row": point.row,
			"column": point.column
		}
		dialog_manager.show_build_confirmation_dialog(info.building_name_pl, info.building_type, action_data)

func _on_road_clicked(_viewport, event, _shape_idx, road):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var my_id = multiplayer.get_unique_id()
		var info = build_manager.can_build_road(road.name, my_id)

		if not info.can_build:
			print(info.reason)
			return

		var action_data = {
			"type": "road",
			"road_name": road.name
		}
		dialog_manager.show_build_confirmation_dialog(info.building_name_pl, "road", action_data)

func _on_tile_clicked(_viewport, event, _shape_idx, tile): 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Lewy klik:", tile.name)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Prawy klik:", tile.name)

# --- WIZUALIZACJA PLANSZY (RPC) ---
@rpc("any_peer", "call_local", "reliable")
func update_map_point(row: int, column: int, owner_player_number: int, should_upgrade: bool):
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
		if (road.player_owner != owner_player_number):
			road.player_owner = owner_player_number
			road.update_visual_game()
		
		var p1 = road.get_node(road.point_a_path)
		var p2 = road.get_node(road.point_b_path)
		
		p1.set_point_owner(owner_player_number)
		p2.set_point_owner(owner_player_number)
		p1.update_visual_game()
		p2.update_visual_game()

# --- LISTA GRACZY I POMOCNIKI ---
@rpc("any_peer", "call_local", "reliable")
func send_players_list_to_clients(players: Dictionary):
	show_all_players(players)

func show_all_players(players: Dictionary):
	if players.is_empty():
		print("Błąd: Brak graczy do wyświetlenia!")
		return
	
	for child in player_list_container.get_children():
		child.queue_free()
		
	for player_id in players:
		var player_name = players[player_id]
		var label = Label.new()
		if player_id == multiplayer.get_unique_id():
			label.text = player_name + " (You)"
		else:
			label.text = player_name
		player_list_container.add_child(label)

func get_map_point(row: int, column: int):
	if not has_node("Map"): return null
	for point in $Map/points.get_children():
		if point.row == row and point.column == column:
			return point
	return null

func is_my_turn() -> bool:
	if turn_manager.turn_order.is_empty(): 
		return false
	var current_player_id = turn_manager.turn_order[turn_manager.current_turn_index]
	return multiplayer.get_unique_id() == current_player_id
