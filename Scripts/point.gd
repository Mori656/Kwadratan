extends Node2D

@export var neighbors: Array:
	set(value): #setter dla active
		neighbors = value

var active: bool:
	set(value): #setter dla active
		active = value
		update_visual_state()

var row: int = 0
var column: int = 0 
var value: int = 0
var player_owner: int = -1 #brak właściciela

@onready var sprite = $AnimatedSprite2D #dziecko sprite tego node

func _ready(): #update tylko raz reszta eventów zależna od scen
	update_visual_state()
	

func update_visual_state():
	if sprite:
		if active:
			sprite.set_frame_and_progress(1, 0)
		else:
			sprite.set_frame_and_progress(0, 0)
