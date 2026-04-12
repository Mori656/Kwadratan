extends Control

@onready var player_name: Label = $PlayerName
@onready var cards_count: Label = $CardsCount
@onready var resources_count: Label = $ResourcesCount
@onready var points_count: Label = $PointsCount

@export_category("Props")

func setup_value(p_name = "user", resources_count = 0, cards = 0, points = 0) -> void:
	set_player_name(p_name)
	set_resources_count(resources_count)
	set_cards_count(cards)
	set_points(points)
	pass

func setup_position():
	pass

func set_player_name(p_name: String):
	player_name.text = p_name

func set_cards_count(value: int):
	cards_count.text = str(value)

func set_resources_count(value: int):
	resources_count.text = str(value)

func set_points(value: int):
	points_count.text = str(value)
