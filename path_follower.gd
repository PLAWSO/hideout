@tool
class_name PathFollower extends Path3D

@export_group("Visibility")
@export var hideCeiling: bool = false
@export var hideProps: bool = false
@export var hideWalls: bool = false

@export_group("Path Following")
@export var time_to_finish: float = 1.0

@onready var target: PathFollow3D = $PathFollow3D

var _is_moving: bool = false

func _ready() -> void:
	start_path_follower()

func start_path_follower() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(target, "progress_ratio", 1, time_to_finish)
	tween.tween_callback(reset_path_follower).set_delay(0.001)

func reset_path_follower() -> void:
	_is_moving = false
	target.set_progress_ratio(0)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not _is_moving:
		# print("restarting path follower")
		_is_moving = true
		start_path_follower()
	pass
