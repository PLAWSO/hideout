class_name PointsCounter extends Control

@onready var label: Label = $Label

var total_points: int = 0

# PUBLIC METHODS
###########################


func reset_points() -> void:
	total_points = 0
	_set_points(total_points)


func add_points(points_to_add: int) -> void:
	total_points += points_to_add
	_set_points(total_points)


# PRIVATE METHODS
###########################


func _set_points(points: int) -> void:
	label.text = "Points: %d" % points