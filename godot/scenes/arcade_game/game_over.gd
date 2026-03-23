extends Control

@onready var result_label = $Panel/MarginContainer/VBoxContainer/ResultLabel
@onready var restart_label: Label = $RestartLabel

func set_text(text: String) -> void:
		result_label.text = text

func show_restart(_visible: bool) -> void:
		restart_label.visible = _visible