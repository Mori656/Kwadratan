extends Node2D

@onready var offered_resources: HBoxContainer = $OfferBox/OfferBoxcontent/OfferInfo/OfferedResources
@onready var wanted_resources: HBoxContainer = $OfferBox/OfferBoxcontent/OfferInfo/WantedResources
var sender_id = -1

func set_trade(trade: Dictionary, sender_id:int = -1):
	self.sender_id = sender_id
	# Czyścimy poprzednią ofertę
	for child in offered_resources.get_children():
		child.queue_free()

	for child in wanted_resources.get_children():
		child.queue_free()

	# Interpretujemy trade
	for resource_name in trade:
		var amount = trade[resource_name]

		if amount == 0:
			continue

		if amount < 0:
			add_resource(offered_resources, resource_name, abs(amount))
		else:
			add_resource(wanted_resources, resource_name, amount)
			
func add_resource(container: Control, resource_name: String, amount: int):
	var resource_container = HBoxContainer.new()
	resource_container.add_theme_constant_override("separation", 0)
	
	var texture_rect = TextureRect.new()
	texture_rect.texture = get_resource_texture(resource_name)

	texture_rect.custom_minimum_size = Vector2(16, 8)
	texture_rect.size = Vector2(16, 8)

	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var amount_label = Label.new()
	amount_label.text = str(amount)
	amount_label.add_theme_font_size_override("font_size", 8)

	resource_container.add_child(texture_rect)
	resource_container.add_child(amount_label)
	
	container.add_child(resource_container)

func get_resource_texture(resource_name: String) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = preload("res://Assets/kwadratan-tileset.png")

	var resource_positions = {
		"wood": 0,
		"iron": 1,
		"oil": 2,
		"coal": 3,
		"uran": 4
	}

	var resource_index = resource_positions[resource_name]

	texture.region = Rect2(resource_index * 32, 161, 32, 16)

	return texture
