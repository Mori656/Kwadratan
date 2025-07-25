extends Node2D

@export var active: bool:
	set(value): #setter dla active
		active = value
		update_visual_state()
		
var row: int = 0
var column: int = 0
var value: int = 0
var resource: int = -1
@onready var sprite = $AnimatedSprite2D #dziecko sprite tego node
@onready var label_value = $Label #dziecko sprite tego node

func _ready(): #update tylko raz reszta eventów zależna od scen
	update_visual_state()
	

func update_visual_state():
	if sprite:
		if active:
			sprite.set_frame_and_progress(0, 0)
		else:
			sprite.set_frame_and_progress(1, 0)
			

func toggle_active():
	active = !active

func set_active(active_value):
		active = active_value;
		
func set_value(num):
	value = num
	label_value.text = str(num)
	
func get_value():
	return value
	
func set_resource(res):
	resource = res
	label_value.text += ("-" + str(res))

func get_resource():
	return resource
