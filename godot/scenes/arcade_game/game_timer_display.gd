class_name GameTimerDisplay extends Control

@onready var time_remaining: Label = $MarginContainer/TimeRemaining

func set_time_remaining(time: int) -> void:
		time_remaining.text = str(time)