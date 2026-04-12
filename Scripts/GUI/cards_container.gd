extends Control

# Zmienne
@onready var inventory: Node2D = $"../../../GameInventory"
@onready var cards_deck: Node2D = $"../../../CardsDeck"
var focused_cards = []
var main_focus_card: CardNode = null
var selected_card: CardNode = null
var dragging = false
var drag_offset = Vector2.ZERO

# Prefab karty
const card_scene = preload("res://Scenes/Prefabs/card.tscn")

func _process(delta):
	if dragging:
		selected_card.global_position = get_global_mouse_position() + drag_offset
		
#@rpc("any_peer", "call_local")
func update_player_cards():
	var player_cards = cards_deck.get_player_cards(multiplayer.get_unique_id())
	
	for child in self.get_children():
		if child is CardNode:
			self.remove_child(child)
	
	for card in player_cards:
		var new_card = card_scene.instantiate()
		new_card.set_card_info(card["id"],card["title"],card["desc"],card["fun"])
		new_card.focused.connect(_card_focus_handler)
		new_card.unfocused.connect(_card_unfocus_handler)
		new_card.card_click.connect(_on_card_click)
		new_card.card_used.connect(_on_card_used)
		self.add_child(new_card)
	
		if selected_card != null:
			if selected_card["id"] == new_card["id"]:
				selected_card = new_card
	
	_cards_placement()


func _on_card_used(card) -> void:
	await cards_deck.on_card_used(card["id"])
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
	var cards_in_container = self.get_children()
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
	var cards_in_container = self.get_children()
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
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			selected_card = null
			_cards_placement()
