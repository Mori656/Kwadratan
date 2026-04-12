extends MultiplayerSpawner

@export var player_scene: PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return
	
	var player: Node2D = player_scene.instantiate()
	player.add_to_group("players")

	# WYLICZ numer gracza
	var ids := multiplayer.get_peers()
	ids.append(multiplayer.get_unique_id())
	ids = ids.duplicate()
	ids.sort()

	var player_number := ids.find(id) + 1
	player.name = "Player%d" % player_number

	# WYLICZ UNIKALNĄ POZYCJĘ
	var spawn_base_position := Vector2(100, 100)
	var offset := Vector2(100 * (player_number - 1), 0)
	var final_position := spawn_base_position + offset

	player.position = final_position

	# Dodanie do sceny
	get_node(spawn_path).call_deferred("add_child", player)

	# Powiedz klientowi, gdzie jest jego postać (tylko jemu)
	player.rpc_id(id, "set_initial_position", final_position)
