extends Node

const DATA_SIZES = [1_000, 10_000, 100_000]
const TEST_COUNT = 100
const FILTER_COUNT = 100

const MONEY_RANGE = 1000
const COINS : Array[int] = [100, 50, 20, 10, 5, 2, 1]

const TEST_FOLDER = "res://Testing/.data"
const RESULT_FOLDER = "res://Testing/.result"

var transactions = []
var transactions_clone = []

var filters = []

func _ready() -> void:
	load_filters(TEST_FOLDER + "/filters.csv")
	test_sorting_and_filtering(1000)
	test_sorting_and_filtering(10000)
	test_sorting_and_filtering(100000)
	#test_coin_change()


func read_csv(csv_path):
	const HEADER = ["timestamp", "itemID", "name", "price"]
	var file = FileAccess.open(csv_path, FileAccess.READ)
	if file == null:
		file.close(); return
	# Valid header field
	var header = Array(file.get_csv_line())
	if header != HEADER:
		file.close(); return
	# Iterate through file
	transactions.clear()
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

func load_filters(filter_path):
	print("Loading filters")
	#const HEADER = ["start","end","itemID"]
	var file = FileAccess.open(filter_path, FileAccess.READ)
	file.get_csv_line()
	while !file.eof_reached():
		var line = Array(file.get_csv_line())
		if len(line) != 3: continue
		line[0] = Timestamp.string_to_ts(line[0])
		line[1] = Timestamp.string_to_ts(line[1])
		filters.append(line)
	print(len(filters),"/",FILTER_COUNT)

func test_sorting_and_filtering(size=1000):
	const HEADERS = ["test_no", "sorting", "filtering"]
	print("Testing sorting and filtering")
	if size not in DATA_SIZES:
		print("Error: Invalid size"); return
	var dir_path = TEST_FOLDER + "/s%d" % size
	var res_file = RESULT_FOLDER + "/s%d/sort-filter.csv" % size
	var file = FileAccess.open(res_file, FileAccess.WRITE)
	file.store_csv_line(HEADERS)
	var dir := DirAccess.open(dir_path)
	var count = 0
	for file_name: String in dir.get_files():
		var row = [file_name]
		file_name = dir_path + "/" + file_name
		read_csv(file_name)
		# Sorting
		var start_time = Time.get_ticks_msec()
		Sorting.quick_sort(transactions, 0, null, "Timestamp")
		var exec_time = Time.get_ticks_msec() - start_time
		row.append(exec_time)
		# Filtering
		var total_time = 0
		for filter in filters:
			start_time = Time.get_ticks_msec()
			filter_revenue(filter[0], filter[1], filter[2])
			exec_time = Time.get_ticks_msec() - start_time
			total_time += exec_time
		row.append(total_time)
		file.store_csv_line(row)
		print(row)
		count += 1
	print(count, "/", TEST_COUNT)
	

# Binary Search Left Bound
func bs_left_boundary(boundary) -> int:
	var start := 0
	#if boundary == null: return start
	var end := len(transactions) - 1
	var mid : int
	var res : int = -1
	while start <= end:
		@warning_ignore("integer_division")
		mid = (start + end) / 2
		if boundary <= transactions[mid]["Timestamp"]:
			res = mid
			end = mid - 1
		else: 
			start = mid + 1
	return res

# Binary Search Right Bound
func bs_right_boundary(boundary) -> int:
	var end := len(transactions) - 1
	#if boundary == null: return end
	var start := 0
	var mid : int
	var res : int = -1
	while start <= end:
		@warning_ignore("integer_division")
		mid = (start + end) / 2
		if boundary >= transactions[mid]["Timestamp"]:
			res = mid
			start = mid + 1
		else: 
			end = mid - 1
	return res

# Filtering
func filter_revenue(start, end, itemID):
	var revenue := 0
	var start_index = bs_left_boundary(start)
	var end_index = bs_right_boundary(end)
	for i in range(start_index, end_index+1):
		var trans = transactions[i]
		if (itemID =="None") or (trans["ItemID"] == itemID):
			# Add revenue
			revenue += trans["Price"]
	return revenue

# Minimum coin change test
func test_coin_change():
	const HEADERS = ["value", "min_coin", "exec_time"]
	print("Testing coin change")
	var res_file = RESULT_FOLDER + "/coin-change.csv"
	var file = FileAccess.open(res_file, FileAccess.WRITE)
	file.store_csv_line(HEADERS)
	for amount in range(10_000):
		var start_time = Time.get_ticks_msec()
		var changes = get_min_coin_change(amount)
		var exec_time = Time.get_ticks_msec() - start_time
		file.store_csv_line([amount, changes["min_coin"], exec_time])
		print("Amount: %.3f VND - Min: %d" % [amount, changes["min_coin"]])

# Minimum coin change solver
func _min_coins(amount: int, dp: Dictionary):
	if amount in dp:
		return dp[amount]["count"]
	var minc = INF
	var step = null
	for c in COINS:
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
