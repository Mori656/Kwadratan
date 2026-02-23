extends Node2D

@export var point_a_path: NodePath
@export var point_b_path: NodePath

@export var is_vertical: bool = false:
	set(value):
		is_vertical = value
		update_visual_editor()

var point_a
var point_b

@export var player_owner: int = -1


func _ready():
	if point_a_path != NodePath():
		point_a = get_node(point_a_path)
		
	if point_b_path != NodePath():
		point_b = get_node(point_b_path)

	update_visual_editor()

# WIDOK W KREATORZE
func update_visual_editor():
	var sprite = $AnimatedSprite2D
	if not sprite:
		return
		sprite.set_frame_and_progress(1, 0)


# WIDOK W GRZE
func update_visual_game():
	var sprite = $AnimatedSprite2D
	if not sprite:
		return
		sprite.set_frame_and_progress(1 + player_owner, 0)
