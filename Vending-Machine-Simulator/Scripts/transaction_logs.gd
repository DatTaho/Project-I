extends Node
class_name TransactionLogs

@export_file("*.csv") var transaction_file : String
const HEADER = ["timestamp", "itemID", "name", "price"]
var transactions = []

func row_counts() -> int:
	return len(transactions)

func get_row(index: int) -> Dictionary:
	return transactions[index]

signal item_added(transaction: Dictionary)
signal table_clear
signal table_update

func add_item(item: Item):
	var row = {
		"Timestamp": Timestamp.now(),
		"ItemID": item.id,
		"Name": item.name,
		"Price": item.price
	}
	transactions.append(row)
	item_added.emit(row)
	table_update.emit()

signal load_transaction(sucess: bool)
func read_csv(csv_path):
	var file = FileAccess.open(csv_path, FileAccess.READ)
	if file == null:
		file.close()
		load_transaction.emit(false)
		return
	# Valid header field
	var header = Array(file.get_csv_line())
	if header != HEADER:
		file.close()
		load_transaction.emit(false)
		return
	# Clear previous data
	transactions.clear()
	table_clear.emit()
	# Iterate through file
	while !file.eof_reached():
		var line = Array(file.get_csv_line())
		if len(line) != 4: continue
		var row = {
			"Timestamp": Timestamp.string_to_ts(line[0]),
			"ItemID": line[1],
			"Name": line[2],
			"Price": int(line[3])
		}
		transactions.append(row)
	file.close()
	# Sort newly loaded data
	Sorting.quick_sort(transactions, 0, null, "Timestamp")
	# Update table
	for row in transactions:
		item_added.emit(row)
	table_update.emit()
	load_transaction.emit(true)

signal save_transaction
func write_csv(csv_path):
	var file = FileAccess.open(csv_path, FileAccess.WRITE)
	file.store_csv_line(HEADER)
	for row in transactions:
		var line = row.values()
		line[0] = Timestamp.ts_to_string(line[0])
		file.store_csv_line(line)
	file.close()
	save_transaction.emit()
