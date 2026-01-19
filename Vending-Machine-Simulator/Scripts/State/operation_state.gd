extends State
class_name OperationState

@export var preview_display : PreviewDisplay
@export var console_display : ConsoleDisplay
@export var control_display : ControlDisplay

func enter_state():
	console_display.visible = false
	preview_display.visible = true

func handle_item_button_toggled(toggled: bool, panel: ItemPanel):
	if toggled == true:
		system.selected_panel = panel
		preview_display.display_item(panel.item)
		control_display.confirm_button.disabled = false
	else:
		system.selected_panel = null
		preview_display.clear_display()
		control_display.confirm_button.disabled = true
