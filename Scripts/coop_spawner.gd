extends MultiplayerSpawner

@export var player_scene: PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return
	
	var player: Node = player_scene.instantiate()
	player.name = str(id)

	# WYLICZ numer gracza na podstawie peer_id (posortuj wszystkich graczy)
	var ids := multiplayer.get_peers()
	ids.append(multiplayer.get_unique_id())  # dodaj też siebie (hosta)
	ids = ids.duplicate()
	ids.sort()  # rosnąco

	var player_number := ids.find(id) + 1  # +1 bo index od 0

	# Ustaw label "Player X"
	if player.has_method("set_player_label"):
		player.set_player_label("Player %d" % player_number)

	get_node(spawn_path).call_deferred("add_child", player)
