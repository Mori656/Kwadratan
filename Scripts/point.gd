extends Node2D

@export var neighbors: Array:
	set(value): #setter dla active
		neighbors = value

var active: bool:
	set(value): #setter dla active
		active = value
		update_visual_state()

@export var row: int:
	set(value): #setter dla row
		row = value 
@export var column: int:
	set(value): #setter dla column
		column = value 
var value: int = 0
@export var player_owner: int = -1 #brak właściciela
@export var factory: bool = false
@export var upgraded_factory: bool = false

@onready var sprite = $AnimatedSprite2D #dziecko sprite tego node

func _ready(): #update tylko raz reszta eventów zależna od scen
	update_visual_state()

#dla kreatora 
func update_visual_state():
	if sprite:
		if active:
			sprite.set_frame_and_progress(1, 0)
		else:
			sprite.set_frame_and_progress(0, 0)

func update_visual_start_game():
	if sprite: #replace for game sprites
		sprite.set_frame_and_progress(2,0)
		

func update_visual_game():
	if sprite:
		if !upgraded_factory: #zwykła fabryka
			sprite.frame = 3 + player_owner # na podstawie ID gracza zmieniamy sprite
			sprite.move_local_y(-5) #zeby prosto bylo 
		else: #ulepszona fabryka
			sprite.frame = 7 + player_owner # na podstawie ID gracza zmieniamy sprite

func place_factory():
	if !factory:
		factory = true
		update_visual_game()

func upgrade_factory():
	if factory and !upgraded_factory:
		upgraded_factory = true
		update_visual_game()

func set_point_owner(ownerId: int):
	player_owner = ownerId
