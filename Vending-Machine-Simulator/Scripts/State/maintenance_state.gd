extends State
class_name MaintenanceState

@export var preview_display : PreviewDisplay
@export var console_display : ConsoleDisplay
@export var item_spawner : ItemSpawner
@export var options : MaintenanceOptions

func enter_state():
	item_spawner.clear()
	preview_display.visible = false
	console_display.visible = true

func handle_item_button_toggled(toggled: bool, panel: ItemPanel):
	if toggled == true:
		system.selected_panel = panel
		options.position = system.selected_panel.get_center()
		options.restock_button.disabled = (
			system.selected_panel.item.id == "P000" or 
			system.selected_panel.item_count == ItemPanel.MAX_ITEMS
		)
		options.visible = toggled
	else:
		system.selected_panel = null
		options.visible = toggled
