@abstract
extends Node
class_name State 

enum Type {OPERATION, MAINTENANCE}

@export var system : VendingMachine

@abstract
func enter_state()

func exit_state():
	if system.selected_panel != null:
		system.selected_panel.button.button_pressed = false

@abstract
func handle_item_button_toggled(toggled: bool, panel: ItemPanel) -> void
