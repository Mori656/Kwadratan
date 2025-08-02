extends Node2D

func _ready():
	if multiplayer.is_server():
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
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
		
@rpc("any_peer")
func request_spawn(id: int):
	if multiplayer.is_server():
		return
	$CoopSpawner.spawn_player(id)
