extends Control

var k1 = 0
var k2 = 0
var map_tiles = -1
var resource_dict = {1:"wood", 2:"brick", 3:"sheep", 4:"grain", 5:"stone"}
@onready var inventory = get_node("../Inventory")
@onready var wood_label = $ResourceContainer/WoodContainer/Count
@onready var brick_label = $ResourceContainer/BrickContainer/Count
@onready var sheep_label = $ResourceContainer/SheepContainer3/Count
@onready var grain_label = $ResourceContainer/GrainContainer4/Count
@onready var stone_label = $ResourceContainer/StoneContainer5/Count

func _ready():
	map_tiles = get_node("../Map/tiles")
	
func _process(delta):
	update_gui()

func update_gui():
	pass
	wood_label.text = str(inventory.resources["wood"])
	brick_label.text = str(inventory.resources["brick"])
	sheep_label.text = str(inventory.resources["sheep"])
	grain_label.text = str(inventory.resources["grain"])
	stone_label.text = str(inventory.resources["stone"])

func _on_button_pressed() -> void:
	k1 = randi() % 6 + 1
	k2 = randi() % 6 + 1
	for tile in map_tiles.get_children():
		if tile.get_value() == k1 + k2:
			inventory.add_resource(resource_dict[tile.get_resource()], 1)
			pass
		pass
	print("Kostka 1:", k1)
	print("Kostka 2:", k2)
	
	pass # Replace with function body.
