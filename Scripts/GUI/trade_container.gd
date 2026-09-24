extends Control

@onready var inventory = $"../../../GameInventory"
@onready var trade_manager = $"../../../Trade"
@onready var trade_container: Control = $"."
@onready var trade_container_pos = trade_container.position

@onready var wood_count_add: Label = $Panel/AddResouceContainer/WoodCountAdd
@onready var iron_count_add: Label = $Panel/AddResouceContainer/IronCountAdd
@onready var oil_count_add: Label = $Panel/AddResouceContainer/OilCountAdd
@onready var coal_count_add: Label = $Panel/AddResouceContainer/CoalCountAdd
@onready var uran_count_add: Label = $Panel/AddResouceContainer/UranCountAdd

@onready var wood_count_remove: Label = $Panel/RemoveResouceContainer/WoodCountRemove
@onready var iron_count_remove: Label = $Panel/RemoveResouceContainer/IronCountRemove
@onready var oil_count_remove: Label = $Panel/RemoveResouceContainer/OilCountRemove
@onready var coal_count_remove: Label = $Panel/RemoveResouceContainer/CoalCountRemove
@onready var uran_count_remove: Label = $Panel/RemoveResouceContainer/UranCountRemove

#------------Labels for trades values-----------#
@onready var remove_wood_value: Label = $Panel/RemoveResouceContainer/RemoveWood/RemoveWoodValue
@onready var remove_iron_value: Label = $Panel/RemoveResouceContainer/RemoveIron/RemoveIronValue
@onready var remove_oil_value: Label = $Panel/RemoveResouceContainer/RemoveOil/RemoveOilValue
@onready var remove_coal_value: Label = $Panel/RemoveResouceContainer/RemoveCoal/RemoveCoalValue
@onready var remove_uran_value: Label = $Panel/RemoveResouceContainer/RemoveUran/RemoveUranValue

var trade_wood_count = 0
var trade_iron_count = 0
var trade_oil_count = 0
var trade_coal_count = 0
var trade_uran_count = 0

var trade_target = "people"

#--------- Show/Hide Trade Container ---------#
func _on_trade_button_toggled(toggled_on: bool) -> void:
	var trade_container_tween = create_tween()
	if toggled_on:
		trade_container_tween.tween_property(trade_container,"position",trade_container_pos ,1)
	else:
		trade_container_tween.tween_property(trade_container,"position",trade_container_pos + Vector2(110,0), 1)
		trade_counts_reset()

#--------- Change Trade Type ---------#
func _on_trade_with_people_button_button_up() -> void:
	trade_target = "people"
	trade_counts_reset()
	trade_values_update()


func _on_trade_with_bank_button_button_up() -> void:
	trade_target = "bank"
	trade_counts_reset()
	trade_values_update()
	pass # Replace with function body.

#--------- Update ---------#
func update_trade_counts():
	if trade_wood_count > 0:
		wood_count_add.text = str(trade_wood_count)
	elif trade_wood_count < 0:
		wood_count_remove.text = str(trade_wood_count)
	else:
		wood_count_add.text = "0"
		wood_count_remove.text = "0"
		
	if trade_iron_count > 0:
		iron_count_add.text = str(trade_iron_count)
	elif trade_iron_count < 0:
		iron_count_remove.text = str(trade_iron_count)
	else:
		iron_count_add.text = "0"
		iron_count_remove.text = "0"
		
	if trade_oil_count > 0:
		oil_count_add.text = str(trade_oil_count)
	elif trade_oil_count < 0:
		oil_count_remove.text = str(trade_oil_count)
	else:
		oil_count_add.text = "0"
		oil_count_remove.text = "0"
		
	if trade_coal_count > 0:
		coal_count_add.text = str(trade_coal_count)
	elif trade_coal_count < 0:
		coal_count_remove.text = str(trade_coal_count)
	else:
		coal_count_add.text = "0"
		coal_count_remove.text = "0"
		
	if trade_uran_count > 0:
		uran_count_add.text = str(trade_uran_count)
	elif trade_uran_count < 0:
		uran_count_remove.text = str(trade_uran_count)
	else:
		uran_count_add.text = "0"
		uran_count_remove.text = "0"

func trade_values_update():
	if trade_target == "bank":
		var player_trades_values = inventory.get_player_trades_values(multiplayer.get_unique_id())
		remove_wood_value.text = str("-",player_trades_values["wood"])
		remove_iron_value.text = str("-",player_trades_values["iron"])
		remove_oil_value.text = str("-",player_trades_values["oil"])
		remove_coal_value.text = str("-",player_trades_values["coal"])
		remove_uran_value.text = str("-",player_trades_values["uran"])
	else:
		remove_wood_value.text = "-1"
		remove_iron_value.text = "-1"
		remove_oil_value.text = "-1"
		remove_coal_value.text = "-1"
		remove_uran_value.text = "-1"
	
	return
#--------- Reset ---------#
func trade_counts_reset():
	trade_wood_count = 0
	trade_iron_count = 0
	trade_oil_count = 0
	trade_coal_count = 0
	trade_uran_count = 0
	update_trade_counts()
	
#--------- Add buttons ---------#
func _on_add_wood_button_up() -> void:
	if trade_target == "bank":
		var res_val = if_bank_has_resource("wood",trade_wood_count)
		if res_val:
			trade_wood_count += res_val
	else:
		trade_wood_count +=1
	update_trade_counts()

func _on_add_iron_button_up() -> void:
	if trade_target == "bank":
		var res_val = if_bank_has_resource("iron",trade_iron_count)
		if res_val:
			trade_iron_count += res_val
	else:
		trade_iron_count +=1
	update_trade_counts()

func _on_add_oil_button_up() -> void:
	if trade_target == "bank":
		var res_val = if_bank_has_resource("oil",trade_oil_count)
		if res_val:
			trade_oil_count += res_val
	else:
		trade_oil_count +=1
	update_trade_counts()

func _on_add_coal_button_up() -> void:
	if trade_target == "bank":
		var res_val = if_bank_has_resource("coal",trade_iron_count)
		if res_val:
			trade_coal_count += res_val
	else:
		trade_coal_count +=1
	update_trade_counts()
	
func _on_add_uran_button_up() -> void:
	if trade_target == "bank":
		var res_val = if_bank_has_resource("uran",trade_uran_count)
		if res_val:
			trade_uran_count += res_val
	else:
		trade_uran_count +=1
	update_trade_counts()

#--------- Remove buttons ---------#
func _on_remove_wood_button_up() -> void:
	var res_val = if_player_has_resource("wood",trade_wood_count)
	if res_val:
		trade_wood_count -= res_val
	update_trade_counts()

func _on_remove_iron_button_up() -> void:
	var res_val = if_player_has_resource("iron",trade_iron_count)
	if res_val:
		trade_iron_count -= res_val
	update_trade_counts()
	
func _on_remove_oil_button_up() -> void:
	var res_val = if_player_has_resource("oil",trade_oil_count)
	if res_val:
		trade_oil_count -= res_val
	update_trade_counts()
	
func _on_remove_coal_button_up() -> void:
	var res_val = if_player_has_resource("coal",trade_coal_count)
	if res_val:
		trade_coal_count -= res_val
	update_trade_counts()
	
func _on_remove_uran_button_up() -> void:
	var res_val = if_player_has_resource("uran",trade_uran_count)
	if res_val:
		trade_uran_count -= res_val
	update_trade_counts()
	
func if_player_has_resource(res,res_count):
	var player_resources = inventory.get_player_resources(multiplayer.get_unique_id())
	var res_value = 1
	if trade_target == "bank":
		var player_trades_values = inventory.get_player_trades_values(multiplayer.get_unique_id())
		res_value = player_trades_values[res]
	if res_count <= 0:
		if player_resources[res] + res_count - res_value > -1:
			return res_value
		else:
			return 0
	else:
		return 1

func if_bank_has_resource(res,res_count):
	var bank_resources = inventory.get_player_resources(0)
	var player_trades_values = inventory.get_player_trades_values(multiplayer.get_unique_id())
	var res_value = player_trades_values[res]
	if res_count >= 0:
		if bank_resources[res] - res_count > 0:
			return 1
		else:
			return 0
	else:
		return res_value
	
	
#--------- Make offer ---------#
func _on_reset_trade_button_up() -> void:
	trade_counts_reset()
	trade_values_update()

func _on_make_offer_button_up() -> void:
	if (trade_wood_count != 0 or trade_coal_count != 0 or trade_oil_count!= 0 or trade_coal_count != 0 or trade_uran_count != 0):
		var trade_offer = prepare_offer()
		trade_manager.create_trade_offer(multiplayer.get_unique_id(),trade_offer,trade_target)

func prepare_offer():
	var trade_offer = {
		"wood":trade_wood_count,
		"iron":trade_iron_count,
		"oil" :trade_oil_count,
		"coal":trade_coal_count,
		"uran":trade_uran_count}
	return trade_offer
	
