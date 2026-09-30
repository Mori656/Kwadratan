extends Node

var turn_order: Array = [] 
var current_turn_index := 0
var current_player_id: int = 0

# Do fazy rozmieszczania
var is_setup_phase: bool = true
var setup_queue: Array = []
var setup_step: String = "factory" #factory lub road

@onready var game = get_parent()

# Po starcie gry
func start_setup_phase(players_list: Array):
	turn_order = players_list
	is_setup_phase = true

	# kolejność przykładowo [1,2,3,3,2,1]
	setup_queue.clear()
	setup_queue.append_array(turn_order)
	var reversed_order = turn_order.duplicate()
	reversed_order.reverse()
	setup_queue.append_array(reversed_order)
	advance_setup_turn()

func advance_setup_turn():
	if setup_queue.is_empty():
		# Koniec fazy wstępnej - przejście do normalnej gry
		is_setup_phase = false
		current_turn_index = 0
		# Synchronizujemy normalną grę (nie faza rozstawiania)
		sync_state.rpc(turn_order[current_turn_index], false, "")
		print("Faza rozstawiania zakończona!")
		return

	var next_peer_id = setup_queue.pop_front()
	# Synchronizujemy fazę wstępną, dla konkretnego gracza, z krokiem "factory"
	sync_state.rpc(next_peer_id, true, "factory")


func end_turn(): #do normalnej gry
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0

	var next_peer_id = turn_order[current_turn_index]
	sync_state.rpc(next_peer_id, false, "")


@rpc("any_peer", "call_local", "reliable")
func sync_state(peer_id: int, phase: bool, step: String):
	current_player_id = peer_id
	is_setup_phase = phase
	setup_step = step

	var my_id = multiplayer.get_unique_id()
	var is_my_turn = my_id == peer_id
	
	# Blokada kości w fazie wstępnej
	if is_setup_phase:
		game.dice_button.disabled = true
	else:
		game.dice_button.disabled = not is_my_turn

	if is_my_turn:
		if is_setup_phase:
			print("FAZA WSTĘPNA: Twoja tura! Zbuduj: ", step)
		else:
			print("Twoja tura w normalnej grze!")

@rpc("any_peer", "call_local", "reliable")
func request_end_turn():
	if multiplayer.is_server() and not is_setup_phase: #nie może być fazy rozstawiania
		end_turn()

@rpc("any_peer", "call_local", "reliable")
func sync_turn_order(order: Array):
	turn_order = order
	print("Zsynchronizowano kolejność tur dla gracza ", multiplayer.get_unique_id(), ": ", turn_order)
