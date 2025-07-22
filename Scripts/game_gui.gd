extends Control

var k1 = 0
var k2 = 0

@onready var inventory = get_node("../Inventory")
@onready var wood_label = $ResourceContainer/WoodContainer/Count
@onready var brick_label = $ResourceContainer/BrickContainer/Count
@onready var sheep_label = $ResourceContainer/SheepContainer3/Count
@onready var grain_label = $ResourceContainer/GrainContainer4/Count
@onready var stone_label = $ResourceContainer/StoneContainer5/Count

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
	print("Kostka 1:", k1)
	print("Kostka 2:", k2)
	
	if not k1 == 6:
		print(inventory.resources.keys()[k1-1])
		inventory.add_resource(inventory.resources.keys()[k1-1], 1)
	pass # Replace with function body.
