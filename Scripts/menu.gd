extends Control

var selected_map_path = "" 

func _ready():
	$MapSelector.connect("map_selected", Callable(self, "_on_map_selected"))

func _on_start_button_up() -> void:
	#get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	$MapSelector.show()
	
func _on_create_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Creator.tscn")
	
func _on_exit_button_up() -> void:
	get_tree().quit()

func _on_map_selected(map_path: String):
	selected_map_path = map_path
	print(selected_map_path)
	$MapSelector.hide()
