extends Node

@export var position_targeter: SecondOrderTargeting
@export var meta_paths: Array[MetaPath] = []

@onready var camera: Node3D = $Camera3D

var meta_path_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position_targeter.initialize(camera.global_position)
	meta_paths[0].start_path_sequence()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera.global_position = position_targeter.get_next_position(_get_current_target_position(), delta)
	camera.look_at(meta_paths[meta_path_index].path_sections[meta_paths[meta_path_index].section_index].object_to_track.global_position, Vector3.UP)

func set_movement_target(index: int) -> void:
	if index >= 0 and index < meta_paths.size():
		meta_path_index = index

func _get_current_target_position() -> Vector3:
	return meta_paths[meta_path_index].get_target_location()

#region Input Handling
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_0"):
		set_movement_target(0)
	if event.is_action_pressed("camera_1"):
		set_movement_target(1)
	# if event.is_action_pressed("camera_2"):
	# 	camera_controller.set_look_target(2)
	# if event.is_action_pressed("camera_3"):
	# 	camera_controller.set_look_target(3)
	# if event.is_action_pressed("camera_4"):
	# 	camera_controller.set_look_target(4)
	# if event.is_action_pressed("camera_5"):
	# 	camera_controller.set_look_target(5)
	# if event.is_action_pressed("camera_6"):
	# 	camera_controller.set_look_target(6)
	# if event.is_action_pressed("camera_7"):
	# 	camera_controller.set_look_target(7)
	# if event.is_action_pressed("camera_8"):
	# 	camera_controller.set_look_target(8)
#endregion
