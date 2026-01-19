extends Control
class_name MaintenanceOptions

@export var system : VendingMachine

@onready var restock_button : Button = $Container/VBox/RestockButton
@onready var options : OptionButton = $Container/VBox/ItemOptions

func _on_main_items_loaded() -> void:
	for item in system.items:
		if item["id"] == "P000":
			options.add_item(item["name"])
		else:
			options.add_item("%s: %.3f VND" % [item["name"], item["price"]])

func get_item(index: int) -> Item:
	var item = Item.new()
	item.id = system.items[index]["id"]
	item.name = system.items[index]["name"]
	item.icon = system.items[index]["icon"]
	item.price = system.items[index]["price"]
	return item

func _on_restock_button_pressed() -> void:
	system.selected_panel.restock()
	system.selected_panel.button.button_pressed= false

func _on_item_options_item_selected(index: int) -> void:
	var item : Item = get_item(index)
	restock_button.disabled = (item.id == "P000")
	system.selected_panel.set_panel_content(item) # count will be set to 0
