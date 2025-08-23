extends Node2D
class_name CardNode

var title = "nazwa karty"
var disc = "opis karty"
var fun = "funkcja karty"

signal focused(card: CardNode)
signal unfocused(card: CardNode)
signal card_click(event: InputEvent, card: CardNode)

func set_card_info(title_of_card = "nazwa",discription_of_card = "opis",function = "fun") -> void:
	title = title_of_card
	disc = discription_of_card
	fun = function
	print("Stworzono kartę ", title)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("focused",self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("unfocused",self)

func highlight():
	self.modulate = Color(0, 0.7, 0.95)
	
func unhighlight():
	self.modulate = Color(1,1,1)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	emit_signal("card_click", event, self)
