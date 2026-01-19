extends HBoxContainer
class_name TransactionRow

@onready var time_label : Label = $TimeLabel
@onready var id_label : Label = $ItemIDLabel
@onready var name_label : Label = $ItemNameLabel
@onready var price_label : Label = $ItemPriceLabel

func set_row(transaction: Dictionary):
	# TimeStamp: int
	time_label.text = Timestamp.ts_to_string(transaction["Timestamp"])
	# ItemID: String
	id_label.text = transaction["ItemID"]
	# Name: String
	name_label.text = transaction["Name"]
	# Price: int
	price_label.text = "%.3f VND" % transaction["Price"]
