class_name PathSection extends Path3D

@export_group("Speed")
@export var speed: float = -1.0
@export var time_to_finish: float = 1.0

@onready var target: PathFollow3D = PathFollow3D.new()

@export var object_to_track: Node3D

var zero_length: bool = false
var length: float = 0.0

func _ready() -> void:
	add_child(target)
	
	length = self.curve.get_baked_length()
	if speed > 0:
		time_to_finish = length / speed

	if length == 0.0:
		zero_length = true