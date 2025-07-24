extends Node2D

var active: bool:
	set(value): #setter dla active
		active = value
		update_visual_state()
		
var row: int = 0
var column: int = 0
var value: int = 0
var player_owner: int = -1 #brak właściciela
@onready var sprite = $Sprite2D #dziecko sprite tego node

func _ready(): #update tylko raz reszta eventów zależna od scen
	update_visual_state()
	

func update_visual_state():
	if sprite:
		if active:
			sprite.modulate = Color(1, 1, 1)  # normalny
		else:
			sprite.modulate = Color(0.5, 0.5, 0.5)  # poszarzony

func toggle_active():
	active = !active

func set_active(active_value):
		active = active_value;
