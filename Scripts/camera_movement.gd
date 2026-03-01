extends Camera2D

@export var min_zoom: Vector2 = Vector2(1,1)
@export var max_zoom: Vector2 = Vector2(3,3)
@export var zoom_speed: float = 0.1
@export var camera_speed: float = 100.0
@export var map_size: Vector2 = Vector2(900,500)
@export var vieport_size: Vector2 = Vector2(640,360)
@export var un_zoomed_vieport_size: Vector2 = Vector2(640,360)
@export var drag_speed := 0.7
var edge_margin = 5
var dragging = false
var mouse_drag_pos = Vector2.ZERO

func _ready() -> void:
	position = Vector2.ZERO

func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var move_vector = Vector2.ZERO
	#Poruszanie sie przy krawędziach
	
	if mouse_position.x <= edge_margin:
		move_vector.x = -camera_speed * delta
	elif mouse_position.x >= un_zoomed_vieport_size.x - edge_margin:
		move_vector.x = camera_speed * delta
		
	if mouse_position.y <= edge_margin:
		move_vector.y = -camera_speed * delta
	elif mouse_position.y >= un_zoomed_vieport_size.y - edge_margin:
		move_vector.y = camera_speed * delta
	position += move_vector
	clamp_camera()

func clamp_camera():
	position.x = clamp(position.x, 0, map_size.x)
	position.y = clamp(position.y, 0, map_size.y)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			mouse_drag_pos = get_global_mouse_position()
			print("save drag pos: ",mouse_drag_pos)
			dragging = event.pressed
		var zoom_factor := 1.0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_factor = 1.0 + zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_factor = 1.0 - zoom_speed
		var new_zoom := zoom * zoom_factor
		new_zoom.x = clamp(new_zoom.x, min_zoom.x, max_zoom.x)
		new_zoom.y = clamp(new_zoom.y, min_zoom.y, max_zoom.y)
		if new_zoom != zoom:
			var mouse_global_pos = get_global_mouse_position()
			var pre_zoom = zoom
			zoom = new_zoom
			position += (mouse_global_pos - position) * (Vector2(1, 1) - pre_zoom / zoom)
		clamp_camera()
	if event is InputEventMouseMotion and dragging:
		position -= event.relative * drag_speed
		
