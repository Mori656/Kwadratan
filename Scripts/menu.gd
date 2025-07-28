extends Control

var selected_map_path = ""

func _ready():
	$MapSelector.connect("map_selected",Callable(self,"_on_map_selected"))

func _on_start_button_up() -> void:
	if multiplayer.is_server():
		# Wywołaj RPC do klientów
		change_map.rpc("res://Scenes/Game.tscn")
		# A host lokalnie zmienia scenę
		change_map("res://Scenes/Game.tscn")

func _on_create_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Creator.tscn")
	
func _on_exit_button_up() -> void:
	get_tree().quit()

func _on_host_button_up() -> void:
	CoopHandler.start_server()
	
func _on_client_button_up() -> void:
	CoopHandler.start_client()

func _on_lobby_button_up() -> void:
	$MapSelector.show()

func _on_map_selected(map_path: String):
	selected_map_path = map_path
	print(selected_map_path)
	$MapSelector.hide()

@rpc("any_peer")
func change_map(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
