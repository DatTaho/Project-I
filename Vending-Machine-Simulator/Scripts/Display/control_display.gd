extends Control
class_name ControlDisplay

@export var system : VendingMachine
@export var transaction_logs : TransactionLogs

# Display control
@onready var confirm_button : Button = $DisplayControl/ConfirmButton
@onready var console_toggle : Button = $DisplayControl/ConsoleToggle

# Balance control
@onready var balance_display = $BalanceDisplay
@onready var add_amount = $BalanceControl/AddAmountSpinBox
@onready var add_button : Button = $BalanceControl/VBox/AddBalanceButton
@onready var return_button : Button = $BalanceControl/VBox/ReturnChangeButton

func set_balance(amount: int):
	system.balance = min(amount, 999)
	balance_display.text = "Balance: %.3f VND" % system.balance
	return_button.disabled = not (system.balance > 0)

func _ready() -> void:
	set_balance(system.balance)
	match system.state:
		State.Type.OPERATION:
			console_toggle.button_pressed = false
		State.Type.MAINTENANCE:
			console_toggle.button_pressed = true
	confirm_button.toggled.connect(system.show_transactions)

func switch_state(new_state: State.Type):
	match new_state:
		State.Type.OPERATION:
			confirm_button.button_pressed = false
			confirm_button.toggle_mode = false
			confirm_button.text = "Confirm"
			confirm_button.disabled = true
		State.Type.MAINTENANCE:
			confirm_button.toggle_mode = true
			confirm_button.text = "Show Transactions"
			confirm_button.disabled = false

func _on_add_balance_button_pressed() -> void:
	var amount = add_amount.value
	set_balance(system.balance + amount) 

func _on_return_change_button_pressed() -> void:
	if system.display_return_changes():
		set_balance(0) 

signal not_enough_balance
func _on_confirm_button_pressed() -> void:
	if system.state != State.Type.OPERATION:
		if system.selected_panel != null:
			system.selected_panel.button.button_pressed = false
		return
	if system.selected_panel == null:
		return
	confirm_button.disabled = true
	if system.balance < system.selected_panel.item.price:
		system.dispense_timer.start(1.0)
		not_enough_balance.emit()
	else:
		system.dispense_timer.start()
		var item = system.selected_panel.dispense()
		set_balance(system.balance - item.price)
		transaction_logs.add_item(item)
	await system.dispense_timer.timeout
	confirm_button.disabled = false

func _on_console_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on == false:
		system.switch_state(State.Type.OPERATION)
		switch_state(State.Type.OPERATION)
	else:
		system.switch_state(State.Type.MAINTENANCE)
		switch_state(State.Type.MAINTENANCE)
