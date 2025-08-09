extends Camera2D

@export var min_zoom: Vector2 = Vector2(1.0,1.0)
@export var max_zoom: Vector2 = Vector2(3,3)
@export var zoom_speed: Vector2 = Vector2(.1,.1)
@export var camera_speed: float = 100.0
@export var map_size: Vector2 = Vector2(640,360)
@export var vieport_size: Vector2 = Vector2(640,360)
@export var un_zoomed_vieport_size: Vector2 = Vector2(640,360)
var edge_margin = 5

func _ready() -> void:
	position = Vector2.ZERO

func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var move_vector = Vector2.ZERO
	
	if mouse_position.x <= edge_margin:
		move_vector.x = -camera_speed * delta
	elif mouse_position.x >= un_zoomed_vieport_size.x - edge_margin:
		move_vector.x = camera_speed * delta
		
	if mouse_position.y <= edge_margin:
		move_vector.y = -camera_speed * delta
	elif mouse_position.y >= un_zoomed_vieport_size.y - edge_margin:
		move_vector.y = camera_speed * delta
	
	position += move_vector
	#Utrzymywanie kamery w polu gry
	
	print("Lewo :", (vieport_size.x / zoom.x) / 2)
	print("vieport x :", vieport_size.x)
	print("zoom x :", zoom.x )
	print("map x :", map_size.x )
	print("Prawo :", map_size.x - (vieport_size.x / zoom.x) / 2)
	position.x = clamp(position.x, 0, map_size.x - (vieport_size.x / zoom.x))
	position.y = clamp(position.y, 0, map_size.y - (vieport_size.y / zoom.y))
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom > min_zoom:
				zoom -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom < max_zoom:
				zoom += zoom_speed
