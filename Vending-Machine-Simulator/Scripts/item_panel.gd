@tool
extends MarginContainer
class_name ItemPanel

@onready var index_label = $Texts/HBox/IndexLabel
@onready var count_label = $Texts/HBox/ItemCountLabel
@onready var item_label = $Texts/ItemLabel
@onready var price_label = $Texts/PriceLabel
@onready var button : Button = $Button

@export_range(0, 98) var index: int
@export var item : Item
const MAX_ITEMS := 10
@export_range(0, MAX_ITEMS) var item_count := 0


func _ready() -> void:
	set_panel_content(item)
	restock()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		set_panel_content(item)
		restock()

func get_center() -> Vector2:
	return Vector2(
		global_position.x + size.x / 2,
		global_position.y + size.y / 2
	)

func switch_state(new_state):
	match new_state:
		State.Type.OPERATION:
			if item_count == 0:
				button.disabled = true
		State.Type.MAINTENANCE:
			button.disabled = false

# Set panel index (from main)
func set_index(value: int):
	index = value
	index_label.text = "%02d" % (value + 1)

func set_item_count(value: int):
	item_count = value
	count_label.text ="Qty: %02d/%02d" % [value, MAX_ITEMS]

# Set panel item, update panel display
func set_panel_content(new_item: Item):
	item = new_item
	item_count = 0
	if item.id == "P000":
		count_label.text = "Qty: --/--"
	else:
		count_label.text ="Qty: %02d/%02d" % [0, MAX_ITEMS]
	item_label.text = item.name
	price_label.text = "%.3f VND" % item.price

# Connect button signal to function from main
func button_connect(callable: Callable):
	button.toggled.connect(callable)

# Dispense items
func dispense() -> Item:
	set_item_count(item_count - 1)
	get_parent().item_spawner.spawn(
		item, get_center() 
		+ Vector2(randf_range(-1.0, 1.0), 0)
	)
	if item_count == 0:
		button.button_pressed = false
		button.disabled = true
	return item

# Restock items
func restock() -> void:
	if item.id == "P000":
		return
	set_item_count(MAX_ITEMS)
	button.disabled = false
