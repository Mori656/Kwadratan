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

@onready var cards_container = $CardsContainer
@onready var cards_container_pos = cards_container.position
@onready var card_scene = preload("res://Scenes/Prefabs/card.tscn")

@onready var dice1 = $DiceContainer/DiceButton/Dice1Sprite
@onready var dice2 = $DiceContainer/DiceButton/Dice2Sprite

@onready var player_display = preload("res://Scenes/Prefabs/player_display.tscn")
@onready var players_displays_container: HBoxContainer = $PlayersDisplays/PlayersDisplaysContainer

var k1 = 0
var k2 = 0
var map_tiles = -1
var resource_dict = {1:"wood", 2:"iron", 3:"oil", 4:"coal", 5:"uran"}
@onready var resource_count = {"wood":wood_count, "iron":iron_count, "oil":oil_count, "coal":coal_count, "uran":uran_count}
@onready var bank_resource_count = {"wood":bank_wood_count, "iron":bank_iron_count, "oil":bank_oil_count, "coal":bank_coal_count, "uran":bank_uran_count}

# zmienne do kart
@onready var card_deposit_container: Area2D = $CardDepositContainer
var focused_cards = []
var main_focus_card: CardNode = null
var selected_card: CardNode = null
var dragging = false
var drag_offset = Vector2.ZERO

@onready var turn_order = CoopHandler.players_in_game.keys() #kolejnośc graczy

func _process(delta):
	if dragging:
		selected_card.global_position = get_global_mouse_position() + drag_offset

func update_gui():
	print("Uruchamiam update")
	rpc("update_player_resources")
	rpc("update_player_cards")
	rpc("update_players_display")
	
@rpc("any_peer", "call_local")
func update_player_resources():
	var player_resources = inventory.get_player_resources(multiplayer.get_unique_id())
	var bank_resources = inventory.get_player_resources(0)
	for i in resource_dict:
		resource_count[resource_dict[i]].text = str(player_resources[resource_dict[i]])
		bank_resource_count[resource_dict[i]].text = str(bank_resources[resource_dict[i]])
		
@rpc("any_peer", "call_local")
func update_player_cards():
	var player_cards = inventory.get_player_cards(multiplayer.get_unique_id())
	
	for child in cards_container.get_children():
		if child is CardNode:
			cards_container.remove_child(child)
	
	for card in player_cards:
		var new_card = card_scene.instantiate()
		new_card.set_card_info(card["id"],card["title"],card["desc"],card["fun"])
		new_card.focused.connect(_card_focus_handler)
		new_card.unfocused.connect(_card_unfocus_handler)
		new_card.card_click.connect(_on_card_click)
		new_card.card_used.connect(_on_card_used)
		cards_container.add_child(new_card)
	
		if selected_card != null:
			if selected_card["id"] == new_card["id"]:
				selected_card = new_card
	
	_cards_placement()

@rpc("any_peer", "call_local")
func update_players_display():
	var inventory_copy = inventory.get_inventory()
	var players = inventory.get_players_list()
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
func _on_card_used(card) -> void:
	await inventory.on_card_used(card["id"])
	selected_card = null
	update_player_cards()

func _card_focus_handler(card) -> void:
	focused_cards.append(card)
	_on_focus_change()

func _card_unfocus_handler(card) -> void:
	if card in focused_cards:
		card.unhighlight()
		focused_cards.erase(card)
	_on_focus_change()

func _on_focus_change():
	var cards_in_container = cards_container.get_children()
	cards_in_container.reverse()
	for c in focused_cards:
		c.unhighlight()
		
	for c in cards_in_container:
		if c in focused_cards:
			c.highlight()
			main_focus_card = c
			return
			
func _on_card_click(event,card):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT :
			if event.pressed and (card == main_focus_card):
				selected_card = card
				dragging = true
				drag_offset = card.global_position - get_global_mouse_position()
				accept_event()
			else:
				dragging = false
				card.check_drop()
				_cards_placement()
				accept_event()


				
func _cards_placement():
	var cards_in_container = cards_container.get_children()
	var cards_count = cards_in_container.size()
	# Środek wachlarza
	var center_position = Vector2(85, 340)
	# rozpiętość wachlarza
	var max_spread = 120
	#miesce zajmowane przez pojedyncze karty( gdy jest ich malo )
	var max_card_spread = 40
	#używana rozpiętość
	var width = min(max_card_spread * (cards_count - 1),max_spread)
	#dodatkowe miejsce dla karty która jest wybrana
	var selected_card_spred = 60
	# Maksymalny kąt odchylenia
	var max_angle = 20
	#Obliczanie odległości między kartami
	var new_step = 0
	if cards_count > 1:
		new_step = width/(cards_count - 1)
		if selected_card:
			if width < selected_card_spred:
				width = min(selected_card_spred,max_spread)
			new_step = (width-selected_card_spred)/(cards_count - 1)
		
	var card_pos = 0 - width/2
	for i in range(cards_count):
		var card = cards_in_container[i]
		#Dodatkowe miejsce dla wybranej karty
		if selected_card == card and cards_count > 1:
			card_pos += selected_card_spred/2.0
		
		var pos_x = center_position.x + card_pos 
		var pos_y = center_position.y + abs(0.2 * card_pos)
		
		var angle = 0
		if card_pos != 0:
			angle = (card_pos/(max_spread/2.0)) * max_angle
		
		card.position = Vector2(pos_x, pos_y)
		card.rotation = deg_to_rad(angle)
		
		#krok kolejnej karty
		card_pos+=new_step
		if selected_card == card:
			card_pos += selected_card_spred/2.0

func _on_dice_button_pressed() -> void:
	k1 = randi() % 6 + 1
	k2 = randi() % 6 + 1
	
	dice1.frame = k1 - 1
	dice2.frame = k2 - 1
	
	#żądanie przydziału zasobów
	rpc_id(1, "give_resources")
	pass


@rpc("any_peer", "call_local")
func give_resources() -> void:
 
	if not multiplayer.is_server():
		return
	var dice_sum = k1 + k2

	var map_points = get_parent().get_parent().get_node("Map/points").get_children()

	for point in map_points:
		# sprawdzamy czy jest fabryka kogoś
		if point.factory and point.player_owner != -1:
			# Pobieramy ID gracza który posiada punkt
			var player_peer_id = turn_order[point.player_owner]
			#Sprawdzamy wszystkie kafelki sąsiadujące z tym punktem
			for tile_coords in point.neighboring_tiles:
				var tile = get_tile_by_coords(tile_coords.y, tile_coords.x)
				
				if tile and tile.active and tile.get_value() == dice_sum:  #kafelek istnieje, jest lądem i value się zgadza
					var amount = 2 if point.upgraded_factory else 1 #mnożnik dla upgrade
					var res_name = resource_dict[tile.get_resource()]
					
					inventory.give_resource_to_players_by_dice(res_name, player_peer_id, amount)#rozdaj surowce

# Funkcja pomocnicza -> z row i column na obiekt
func get_tile_by_coords(r: int, c: int):
	# Pobieramy listę wszystkich kafelków za każdym razem
	var tiles_list = get_parent().get_parent().get_node("Map/tiles").get_children()
	for tile in tiles_list:
		if tile.row == r and tile.column == c:
			return tile    
	return null




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

func _on_draw_card_button_button_up() -> void:
	inventory.on_card_draw()
	pass # Replace with function body.
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			selected_card = null
			_cards_placement()
