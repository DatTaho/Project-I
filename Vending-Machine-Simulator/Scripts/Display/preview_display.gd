extends Control
class_name PreviewDisplay

@export var system : VendingMachine
@onready var item_view = $ItemView
@onready var return_view = $ReturnView
@onready var top_label = $TopLabel
@onready var bottom_label = $BottomLabel

func display_changes(changes: Dictionary):
	return_view.visible = true
	item_view.visible = false
	top_label.text = "Returning changes"
	return_view.clear()
	if changes["min_coin"] == null:
		return_view.add_text("\tError: Can't return money!\n")
		return_view.add_text("\tPlease check coin setting")
		bottom_label.text = ""
	else:
		for c in system.coins: if c in changes:
			return_view.add_text("\tx%d - %.3f VND\n" % [changes[c], c])
		bottom_label.text = "Total count: %d" % changes["min_coin"]

func display_item(item: Item) -> void:
	item_view.visible = true
	return_view.visible = false
	top_label.text = "Would you like to buy"
	item_view.texture = load(item.icon)
	bottom_label.text = "for %.3f VND?" % item.price

func clear_display() -> void:
	item_view.visible = true
	return_view.visible = false
	top_label.text = "Select an item"
	item_view.texture = null
	bottom_label.text = "for purchase"


func _on_control_display_not_enough_balance() -> void:
	var prev_state = bottom_label.text
	bottom_label.text = "Not enough balance!"
	await system.dispense_timer.timeout
	bottom_label.text = prev_state
