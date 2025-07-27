extends CharacterBody2D

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 500.0
	move_and_slide()
	
func set_player_label(text: String) -> void:
	var label := get_node_or_null("Label")
	if label:
		label.text = text
