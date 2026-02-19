extends Control

func _ready():
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()

func _on_viewport_resized():
	custom_minimum_size.x = min(get_viewport_rect().size.x, 1200)