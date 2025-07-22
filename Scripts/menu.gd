extends Control


func _on_start_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_create_button_up() -> void:
	### get_tree().change_scene_to_file("res://Scenes/Game.tscn") <---- tu wstaw swoją scenę :) 
	pass # Replace with function body.
	
func _on_exit_button_up() -> void:
	get_tree().quit()
