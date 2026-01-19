extends Resource
class_name Timestamp

static func from_date(year:int, month:int, day:int, hour:=0, minute:=0, second:=0) -> int:
	return Time.get_unix_time_from_datetime_dict({
		"year": year, "month": month, "day": day,
		"hour": hour, "minute": minute, "second": second
	})

static func now() -> int:
	var now_dict = Time.get_datetime_dict_from_system()
	return Time.get_unix_time_from_datetime_dict(now_dict)

static func ts_to_string(timestamp: int, type:="all") -> String:
	var dt = Time.get_datetime_dict_from_unix_time(timestamp)
	var date_str = "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]
	var time_str = "%02d:%02d:%02d" % [dt["hour"], dt["minute"], dt["second"]]
	match type:
		"date": return date_str
		"time": return time_str
		"all": return date_str + " " + time_str
	return ""

static func is_leep(year: int):
	return (year % 4 == 0 and year % 100 != 0) or year % 400 == 0

static func string_to_ts(time_string: String):
	var args : PackedStringArray = time_string.split(" ")
	if len(args) != 2: return null

	var date_args : Array = args[0].split("-")
	var time_args : Array = args[1].split(":")
	if len(date_args) != 3 or len(time_args) != 3:
		return null
	for i in 3:
		if !date_args[i].is_valid_int(): return null
		else: date_args[i] = int(date_args[i])
		if !time_args[i].is_valid_int(): return null
		else: time_args[i] = int(time_args[i])
	
	# Check year
	if date_args[0] < 0: return null
	# Check month and day
	if date_args[2] < 0: return null
	match date_args[1]:
		1, 3, 5, 7, 8, 10, 12:
			if date_args[2] > 31:
				return null
		4, 6, 9, 11:
			if date_args[2] > 30:
				return null
		2:
			if date_args[2] > 28 + int(is_leep(date_args[0])):
				return null
		_: return null
	# Check time
	if (time_args[0] < 0 or time_args[0] > 23
		or time_args[1] < 0 or time_args[1] > 59
		or time_args[2] < 0 or time_args[2] > 59
	): return null

	var ts = Time.get_unix_time_from_datetime_dict({
		"year": date_args[0], "month": date_args[1], "day": date_args[2],
		"hour": time_args[0], "minute": time_args[1], "second": time_args[2]
	})
	return ts
