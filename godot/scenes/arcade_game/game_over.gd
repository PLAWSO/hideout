extends Control

@onready var result_label = $Panel/MarginContainer/VBoxContainer/ResultLabel

func set_text(text: String) -> void:
		result_label.text = text
