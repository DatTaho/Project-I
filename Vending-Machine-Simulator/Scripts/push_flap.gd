extends Control

@onready var visual = $PushFlapVisual

func _on_mouse_entered() -> void:
	visual.visible = false

func _on_mouse_exited() -> void:
	visual.visible = true
