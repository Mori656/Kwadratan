extends Control


func _on_start_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_create_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Creator.tscn")
	
func _on_exit_button_up() -> void:
	get_tree().quit()
