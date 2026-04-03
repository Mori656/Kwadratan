extends Node2D

#jeżeli jest aktywny - to znaczy że jest lądem -> więc ma jakieśtam zasoby
@export var active: bool:
	set(value): #setter dla active
		active = value
		update_creator_visual_state()
		
@export var row: int = 0
@export var column: int = 0
var value: int = 0
var resource: int = -1
@onready var sprite = $AnimatedSprite2D #dziecko sprite tego node
@onready var label_value = $Label #dziecko sprite tego node

func _ready(): #update tylko raz reszta eventów zależna od scen
	update_creator_visual_state()
	

func update_creator_visual_state():
	if sprite:
		if !active:
			sprite.set_frame_and_progress(0, 0) #woda
		else: #ląd
			sprite.set_frame_and_progress(6, 0)
	else:
		return

func update_game_visual_state():
	if sprite:
		if !active:
			sprite.set_frame_and_progress(0, 0) #woda
		else: #1:"wood", 2:"iron", 3:"oil", 4:"coal", 5:"uran"
			sprite.set_frame_and_progress(resource, 0)
	else:
		return

func toggle_active():
	active = !active

func set_active(active_value):
		active = active_value;
		
func set_value(num): #W wywołaniu skryptu mapy
	value = num
	label_value.text = str(num)
	
func get_value():
	return value
	
func set_resource(res): #W wywołaniu skryptu mapy
	resource = res
	label_value.text += ("-" + str(res))
	update_game_visual_state()

func get_resource():
	return resource
