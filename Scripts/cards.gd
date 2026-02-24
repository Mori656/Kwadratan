extends Node2D
class_name CardNode

var id = 0
var title = "nazwa karty"
var desc = "opis karty"
var fun = "funkcja karty"

signal focused(card: CardNode)
signal unfocused(card: CardNode)
signal card_click(event: InputEvent, card: CardNode)
signal card_used(card: CardNode)

@onready var name_container = $Container/CardName
@onready var desc_container = $Container/CardDescription

func _ready() -> void:
	update_card_info()

func set_card_info(id_of_card = 0,title_of_card = "nazwa",description_of_card = "opis",function = "fun") -> void:
	id = id_of_card
	title = title_of_card
	desc = description_of_card
	fun = function

func update_card_info():
	name_container.text = title
	desc_container.text = desc
	
func _on_area_2d_mouse_entered() -> void:
	emit_signal("focused",self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("unfocused",self)

func highlight():
	self.modulate = Color(0, 0.7, 0.95)
	
func unhighlight():
	self.modulate = Color(1,1,1)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	emit_signal("card_click", event, self)
	
func check_drop():
	var areas = get_node("Area2D").get_overlapping_areas()
	for area in areas:
		if area.has_method("on_card_dropped"):
			area.on_card_dropped(self)
			emit_signal("card_used",self)
			return
