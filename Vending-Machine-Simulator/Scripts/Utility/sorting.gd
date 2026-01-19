extends Resource
class_name Sorting

static func quick_sort(arr, low=0, high=null, by_idx=null):

	if high == null: high = len(arr) - 1
	if low < high:
		var pivot = _partition(arr, low, high, by_idx)
		quick_sort(arr, low, pivot - 1, by_idx)
		quick_sort(arr, pivot + 1, high, by_idx)
	
static func _partition(arr, low, high, by) -> int:
	var pivot = arr[high][by] if by != null else arr[high]
	var i = low - 1
	var value
	for j in range(low, high):
		value = arr[j][by] if by != null else arr[j]
		if (value < pivot):
			i += 1
			_swap(arr, i, j)
	_swap(arr, i + 1, high);  
	return i + 1;

static func _swap(arr, i, j) -> void:
	var temp
	temp = arr[i]
	arr[i] = arr[j]
	arr[j] = temp
	
