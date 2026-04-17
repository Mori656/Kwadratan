extends Node

var turn_order: Array = [] 
var current_turn_index := 0

@onready var game = get_parent()

@rpc("any_peer", "call_local", "reliable")
func update_turn(peer_id: int):
	var my_id = multiplayer.get_unique_id()
	var is_my_turn = my_id == peer_id
	game.dice_button.disabled = not is_my_turn
	
	if is_my_turn:
		print("Tura gracza", peer_id)
	else:
		print("Tura gracza", peer_id)

@rpc("any_peer", "call_local", "reliable")
func request_end_turn():
	if multiplayer.is_server():
		end_turn()

func end_turn():
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0

	var next_peer_id = turn_order[current_turn_index]
	update_turn.rpc(next_peer_id)
