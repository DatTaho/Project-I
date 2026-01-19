extends RigidBody2D
class_name DropItem

@onready var sprite2d : Sprite2D = $Sprite2D

func set_texture(item: Item):
	sprite2d.texture = load(item.icon)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		queue_free()
