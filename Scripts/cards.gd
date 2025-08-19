extends Node2D
class_name CardNode

var title = "nazwa karty"
var disc = "opis karty"
var fun = "funkcja karty"

func set_card_info(title_of_card = "nazwa",discription_of_card = "opis",function = "fun") -> void:
	title = title_of_card
	disc = discription_of_card
	fun = function
	print("Stworzono kartę ", title)
