extends Control
class_name ConsoleDisplay

@export var system : VendingMachine
@onready var logs : RichTextLabel = $ConsoleLogs
@onready var cmd : LineEdit = $ComandLine

const DEFAULT = """Vending Machine Console
Version 1.1
"""

@export var transaction_logs : TransactionLogs
var transactions

func _ready() -> void:
	logs.add_text(DEFAULT)
	transactions = transaction_logs.transactions

func _on_comand_line_text_submitted(new_text: String) -> void:
	if new_text == "": return
	cmd.text = ""
	query(new_text)

const HELP_STR := """Showing list of comands:
	help
		Show all avalable commands
	clear
		Clear console display
	set-coins <values>	
		Set the machine's list of accepted
		money values, seperated by space
	get-coins
		Return list of accepted money
		values in increasing order
"""

func logging(text: String):
	logs.add_text("[%s] %s\n" % 
	[Timestamp.ts_to_string(Timestamp.now(), "time"), text])

func query(command: String):
	logging("Query: %s" % command)
	var args := command.split(" ")
	match args[0]:
		"help": logs.add_text(HELP_STR)
		# Commands on system
		"clear": logs.clear(); logs.add_text(DEFAULT)
		"set-coins": set_coins(args)
		"get-coins": get_coins()
		"make-change": get_min_coin_change(args)
		# Commands on transactions
		"show-transactions": show_transactions()
		"get-revenue": get_revenue()
		# Default
		_: logs.add_text("Invalid command!\n")

func set_coins(args):
	system.coins.clear()
	for i in len(args)-1:
		var coin = int(args[i+1])
		if coin in system.coins: continue
		system.coins.append(coin)
	system.coins.sort()
	system.coins.reverse()
	logs.add_text("Set coins sucessfully!\n")

func get_coins():
	var msg := "System coins:"
	for i in range(len(system.coins), 0, -1):
		msg += " %d" % system.coins[i - 1]
	logs.add_text(msg + "\n")

func get_min_coin_change(args):
	var amount := int(args[1]) if len(args) >= 2 else system.balance
	var changes = system.get_min_coin_change(amount)
	log_changes(changes)

func log_changes(changes: Dictionary):
	if changes["min_coin"] == null:
		logs.add_text("No solution\n"); return 
	logs.add_text("MinCount: %d\n" % changes["min_coin"])
	for c in system.coins:
		if c in changes:
			logs.add_text("\tx%d - %.3f VND\n" % [changes[c], c])

func show_transactions():
	logs.add_text("TimeStamp, ItemID, Name, Price\n")
	for t in transactions:
		logs.add_text("%d, %s, %s, %.3f VND\n" % t)

func get_revenue():
	var revenue := 0
	for t in transactions: 
		revenue += t[-1]
	logs.add_text("Total revenue: %.3f VND" % revenue)

func _on_transaction_logs_load_transaction(success: bool) -> void:
	logging("Load transactions: " + ("SUCCESS" if success else "FAILED"))

func _on_transaction_logs_save_transaction() -> void:
	logging("Save transactions")
