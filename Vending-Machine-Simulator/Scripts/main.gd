@tool
extends Control
class_name VendingMachine

@export_group("Items Data", "items_")
@export_file("*.cfg") var items_file : String
@onready var inventory = $HBox/ItemView/ItemsDisplay/InventoryGrid
var items := []
signal items_loaded

# System state: Operation | Maintenance
@onready var operation_state : OperationState = $States/OperationState
@onready var maintenance_state : MaintenanceState = $States/MaintenanceState
@export var state : State.Type
var op_state : State

# Currently selected item panel
var selected_panel : ItemPanel
var panels : Array[ItemPanel] = []

# System configs
@export var balance: int
@export var coins : Array[int]
@export var dispense_delay : float

@onready var dispense_timer : Timer = $DispenseTimer
@onready var transactions_dislay = $HBox/ItemView/TransactionsDisplay
@onready var items_display = $HBox/ItemView/ItemsDisplay
@onready var preview_display = $HBox/SideView/DisplayPanel/PreviewDisplay
@onready var console_display = $HBox/SideView/DisplayPanel/ConsoleDisplay

func _ready() -> void:
	# Set up timer
	dispense_timer.wait_time = dispense_delay
	# Set up item panels
	var index := 0
	for panel : ItemPanel in inventory.get_children():
		panel.set_index(index); index += 1
		panel.button_connect(
			_on_item_panel_button_toggled
			.bind(panel)
		)
		panels.append(panel)
	if not Engine.is_editor_hint():
		# Load items data
		load_items(items_file)
		# Set state
		switch_state(state)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		coins.sort()
		coins.reverse()

# Load item data
func load_items(items_path: String):
	var items_data := ConfigFile.new()
	var success = (items_data.load(items_path) == OK)
	console_display.logging("Load items data: " + ("SUCCESS" if success else "FAILED"))
	if success:
		for id in items_data.get_sections():
			var pname = items_data.get_value(id, "product_name")
			var price = items_data.get_value(id, "price")
			var icon = items_data.get_value(id, "icon_path")
			items.append({"id": id, "name": pname, "icon": icon, "price": price})
	items_loaded.emit()

# Switch state
func switch_state(new_state: State.Type):
	if op_state is State: op_state.exit_state()
	match new_state:
		State.Type.OPERATION: 
			op_state = operation_state
		State.Type.MAINTENANCE:
			op_state = maintenance_state
	state = new_state
	for panel in panels:
		panel.switch_state(new_state)
	if op_state is State: op_state.enter_state()

# Handle item panels control
func _on_item_panel_button_toggled(toggled: bool, panel: ItemPanel) -> void:
	op_state.handle_item_button_toggled(toggled, panel)

# Switch between item view and transaction view
func show_transactions(toggled : bool):
	console_display.logging("Show transactions: %s" % str(toggled).to_upper())
	transactions_dislay.visible = toggled
	items_display.visible = not toggled

# Display changes
func display_return_changes() -> bool:
	console_display.logging("Return change")
	var changes = get_min_coin_change(balance)
	# Unselect panel
	if selected_panel != null:
		selected_panel.button.button_pressed = false
	# Display return changes
	preview_display.display_changes(changes)
	console_display.log_changes(changes)
	# Success flag
	return (changes["min_coin"] != null)

# Minimum coin change solver
func _min_coins(amount: int, dp: Dictionary):
	if amount in dp:
		return dp[amount]["count"]
	var minc = INF
	var step = null
	for c in coins:
		var diff := amount - c
		if diff < 0: continue
		var count = 1 + _min_coins(diff, dp)
		if minc > count:
			step = c
			minc = count
	dp[amount] = {"step": step, "count": minc}
	return minc

# Return min coin change solution
func get_min_coin_change(amount: int) -> Dictionary:
	var dp := {0: {"step": null, "count": 0}}
	var result = _min_coins(amount, dp)
	var changes : Dictionary = {}
	if result == INF:
		changes["min_coin"] = null
	else:
		changes["min_coin"] = result
		while amount != 0:
			var step = dp[amount]["step"]
			changes[step] = changes.get(step, 0) + 1
			amount -= step
	return changes
