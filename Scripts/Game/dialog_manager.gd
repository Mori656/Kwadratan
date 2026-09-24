extends Node

@onready var game = get_parent()

var confirm_dialog: ConfirmationDialog
var cost_container: HBoxContainer
var question_label: Label
var pending_build_action: Dictionary = {}

func _ready():
	setup_confirmation_dialog()

# Inicjalizacja okienka dialogowego
func setup_confirmation_dialog():
	confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Potwierdzenie budowy"
	confirm_dialog.ok_button_text = " ✔  Kup "
	confirm_dialog.cancel_button_text = " ✖  Anuluj "
	confirm_dialog.confirmed.connect(_on_build_confirmed)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 10)
	
	question_label = Label.new()
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(question_label)
	
	cost_container = HBoxContainer.new()
	cost_container.alignment = BoxContainer.ALIGNMENT_CENTER
	cost_container.add_theme_constant_override("separation", 12)
	main_vbox.add_child(cost_container)
	
	confirm_dialog.add_child(main_vbox)
	add_child(confirm_dialog)

# Pobieranie tekstury surowca z GUI
func get_resource_texture(res_name: String) -> Texture2D:
	var res_container = game.gui.get_node_or_null("PlayerResourcesContainer/Panel")
	if not res_container:
		return null
		
	var node_map = {
		"wood": res_container.get_node_or_null("WoodImage"),
		"iron": res_container.get_node_or_null("IronImage"),
		"oil": res_container.get_node_or_null("OilImage"),
		"coal": res_container.get_node_or_null("CoalImage"),
		"uran": res_container.get_node_or_null("UranImage")
	}
	
	var sprite = node_map.get(res_name)
	if not sprite or not sprite.texture:
		return null

	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = sprite.texture
	
	if "region_enabled" in sprite and sprite.region_enabled:
		atlas_tex.region = sprite.region_rect
	else:
		atlas_tex.region = Rect2(Vector2.ZERO, sprite.texture.get_size())
		
	return atlas_tex

# Otwieranie dialogu z ikonami kosztów
func show_build_confirmation_dialog(building_name_pl: String, building_type: String, action_data: Dictionary):
	pending_build_action = action_data
	question_label.text = "Czy chcesz zbudować %s?" % building_name_pl
	
	for child in cost_container.get_children():
		child.queue_free()
		
	var cost = game.game_inventory.COSTS.get(building_type, {})
	for res in cost:
		var amount = cost[res]
		
		var item_box = HBoxContainer.new()
		item_box.add_theme_constant_override("separation", 4)
		
		var count_label = Label.new()
		count_label.text = str(amount)
		
		var icon_rect = TextureRect.new()
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.custom_minimum_size = Vector2(24, 24)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = get_resource_texture(res)
		
		item_box.add_child(count_label)
		item_box.add_child(icon_rect)
		
		cost_container.add_child(item_box)
		
	confirm_dialog.popup_centered()

# Wysyłanie żądania do serwera po zatwierdzeniu
func _on_build_confirmed():
	if pending_build_action.is_empty(): 
		return
		
	var type = pending_build_action.get("type")
	
	if type == "factory" or type == "nuclear_power_plant":
		game.build_manager.request_place_factory.rpc_id(1, pending_build_action.row, pending_build_action.column)
	elif type == "road":
		game.build_manager.request_place_road.rpc_id(1, pending_build_action.road_name)
		
	pending_build_action.clear()
