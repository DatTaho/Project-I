extends Node
class_name ItemSpawner

@export var drop_item : PackedScene

func spawn(item: Item, pos: Vector2):
	var drop : DropItem = drop_item.instantiate()
	drop.position = pos
	add_child(drop)
	drop.set_texture(item)

func clear():
	for drop in get_children():
		drop.queue_free()
