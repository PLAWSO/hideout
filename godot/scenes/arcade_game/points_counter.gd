class_name PointsCounter extends Control

@onready var score_label: Label = $MarginContainer/ScoreLabel
@onready var personal_best_label: Label = $MarginContainer2/PersonalBestLabel

var total_points: int = 0


func _ready() -> void:
	set_personal_best(JSBridge.get_personal_best())

# PUBLIC METHODS
###########################


func reset() -> void:
	total_points = 0
	_set_points(total_points)


func add_points(points_to_add: int) -> void:
	total_points += points_to_add
	_set_points(total_points)


func get_personal_best() -> int:
	return JSBridge.get_personal_best()


func set_personal_best(points: int) -> void:
	personal_best_label.text = str(points)


# PRIVATE METHODS
###########################


func _set_points(points: int) -> void:
	score_label.text = str(points)

