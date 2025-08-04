extends Node2D

func _ready():
	if multiplayer.is_server():
		#dodaj mapę wybraną 
		#ładujemy nową mapę - wszędzie
		load_map.rpc(CoopHandler.selected_map)
		# Spawnuje wszystkich, którzy są podłączeni
		for id in multiplayer.get_peers():
			$CoopSpawner.spawn_player(id)
		# Spawnuje siebie
		$CoopSpawner.spawn_player(multiplayer.get_unique_id())
	else:
		# Klient prosi hosta o spawn
		request_spawn.rpc_id(1, multiplayer.get_unique_id())

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
		
@rpc("any_peer")
func request_spawn(id: int):
	if multiplayer.is_server():
		return
	$CoopSpawner.spawn_player(id)
