extends Control

@export var system : VendingMachine
@export var transaction_logs : TransactionLogs

@onready var table = $Contents/Table/VBox
@export var row_scene : PackedScene


func _ready() -> void:
	transaction_logs.table_clear.connect(table_clear)
	transaction_logs.item_added.connect(table_add_row)
	transaction_logs.table_update.connect(filter_update)

func table_clear():
	for row in table.get_children():
		row.queue_free()

func table_add_row(transaction: Dictionary):
	var row : TransactionRow = row_scene.instantiate()
	table.add_child(row)
	row.set_row(transaction)

#func reload_transactions_data():
	#for row in table.get_children():
		#row.queue_free()
	#for transaction in transaction_logs.transactions:
		#var row : TransactionRow = row_scene.instantiate()
		#table.add_child(row)
		#row.set_row(transaction)
	#filter_update()

func _on_main_items_loaded() -> void:
	for item in system.items:
		if item["id"] != "P000":
			item_options.add_item(item["name"])

# Filters
@onready var item_options: OptionButton =  $Contents/Bottom/VBox/ItemFilter/Options
@onready var dc1_date : LineEdit = $Contents/Bottom/VBox/DateFilter/DateComponent1/Date
@onready var dc1_time : LineEdit = $Contents/Bottom/VBox/DateFilter/DateComponent1/Time
@onready var dc2_date : LineEdit = $Contents/Bottom/VBox/DateFilter/DateComponent2/Date
@onready var dc2_time : LineEdit = $Contents/Bottom/VBox/DateFilter/DateComponent2/Time
@onready var revenue_label : Label = $Contents/Bottom/VBox/RevenueLabel

@onready var dc_states = {
	"dc1_date": "", "dc1_time": dc1_time.placeholder_text,
	"dc2_date": "", "dc2_time": dc2_time.placeholder_text,
}
var filter_item_id : String = "None"
var filter_start_ts		# int | null
var filter_end_ts		# int | null

func filter_update():
	var revenue := 0
	var start_index = _bs_left_boundary(filter_start_ts)
	var end_index = _bs_right_boundary(filter_end_ts)

	var rows = table.get_children()
	for i in transaction_logs.row_counts():
		var trans = transaction_logs.get_row(i)
		if (i >= start_index and i <= end_index 
		and (filter_item_id =="None" 
		or trans["ItemID"] == filter_item_id)):
			# Show row
			rows[i].visible = true
			# Add revenue
			revenue += trans["Price"]
		else:
			rows[i].visible = false
	revenue_label.text = "Revenue: " + int_to_vnd(revenue)

func int_to_vnd(amount: int):
	var i = len(str(amount)) % 3
	if i == 0: i = 3
	var res = ""
	for c in str(amount):
		res += c; i -= 1
		if i == 0:
			i = 3; res += "."
	res += "000 VND"
	return res
		

func _bs_left_boundary(boundary) -> int:
	var start := 0
	if boundary == null: return start
	var end := transaction_logs.row_counts() - 1
	var mid : int
	var res : int = -1
	while start <= end:
		@warning_ignore("integer_division")
		mid = (start + end) / 2
		if boundary <= transaction_logs.get_row(mid)["Timestamp"]:
			res = mid
			end = mid - 1
		else: 
			start = mid + 1
	return res

func _bs_right_boundary(boundary) -> int:
	var end := transaction_logs.row_counts() - 1
	if boundary == null: return end
	var start := 0
	var mid : int
	var res : int = -1
	while start <= end:
		@warning_ignore("integer_division")
		mid = (start + end) / 2
		if boundary >= transaction_logs.get_row(mid)["Timestamp"]:
			res = mid
			start = mid + 1
		else: 
			end = mid - 1
	return res

func _on_item_options_item_selected(index: int) -> void:
	if index == 0: filter_item_id = "None"
	else: filter_item_id = system.items[index]["id"]
	filter_update()

func _on_dc1_date_submitted(new_text: String) -> void:
	if new_text == "":
		dc_states["dc1_date"] = dc1_date.text
		dc1_time.editable = false
		dc1_time.text = dc1_time.placeholder_text
		filter_start_ts = null
	else:
		var new_ts = Timestamp.string_to_ts("%s %s" % [new_text, dc1_time.text])
		if new_ts != null:
			dc1_date.text = Timestamp.ts_to_string(new_ts, "date")
			dc_states["dc1_date"] = dc1_date.text
			dc1_time.editable = true
			filter_start_ts = new_ts
		else:
			dc1_date.text = dc_states["dc1_date"]
	filter_update()

func _on_dc1_time_submitted(new_text: String):
	if new_text == "": new_text = dc1_time.placeholder_text
	var new_ts = Timestamp.string_to_ts("%s %s" % [dc1_date.text, new_text])
	if new_ts != null:
		dc1_time.text = Timestamp.ts_to_string(new_ts, "time")
		dc_states["dc1_time"] = dc1_time.text
		filter_start_ts = new_ts
	else:
		dc1_time.text = dc_states["dc1_time"]
	filter_update()

func _on_dc2_date_submitted(new_text: String) -> void:
	if new_text == "":
		dc_states["dc2_date"] = dc2_date.text
		dc2_time.editable = false
		dc2_time.text = dc2_time.placeholder_text
		filter_end_ts = null
	else:
		var new_ts = Timestamp.string_to_ts("%s %s" % [new_text, dc2_time.text])
		if new_ts != null:
			dc2_date.text = Timestamp.ts_to_string(new_ts, "date")
			dc_states["dc2_date"] = dc2_date.text
			dc2_time.editable = true
			filter_end_ts = new_ts
		else:
			dc2_date.text = dc_states["dc2_date"]
	filter_update()

func _on_dc2_time_submitted(new_text: String):
	if new_text == "": new_text = dc2_time.placeholder_text
	var new_ts = Timestamp.string_to_ts("%s %s" % [dc2_date.text, new_text])
	if new_ts != null:
		dc2_time.text = Timestamp.ts_to_string(new_ts, "time")
		dc_states["dc2_time"] = dc2_time.text
		filter_end_ts = new_ts
	else:
		dc2_time.text = dc_states["dc2_time"]
	filter_update()

@onready var window : FileDialog = $FileDialog
@onready var save_button : Button = $Contents/Bottom/VBox/HBox/ButtonsPanel/HBox/SaveButton
@onready var load_button : Button = $Contents/Bottom/VBox/HBox/ButtonsPanel/HBox/LoadButton

func enable_buttons(enable: bool):
	save_button.disabled = not enable
	load_button.disabled = not enable

func _on_save_button_pressed() -> void:
	enable_buttons(false)
	window.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	window.visible = true

func _on_load_button_pressed() -> void:
	enable_buttons(false)
	window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	window.visible = true

func _on_file_dialog_canceled() -> void:
	enable_buttons(true)

func _on_file_dialog_file_selected(path: String) -> void:
	match window.file_mode:
		FileDialog.FILE_MODE_SAVE_FILE:	# Save
			transaction_logs.write_csv(path)
		FileDialog.FILE_MODE_OPEN_FILE:	# Load
			transaction_logs.read_csv(path)
	enable_buttons(true)
