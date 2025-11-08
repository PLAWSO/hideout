extends Node

@export var meta_paths: Array[MetaPath] = []

@onready var camera: Node3D = $Camera3D
@onready var position_targeter: SecondOrderTargeting = SecondOrderTargeting.new()
@onready var x_look_targeter: SecondOrderTargetingQuaternion = SecondOrderTargetingQuaternion.new()
@onready var y_look_targeter: SecondOrderTargetingQuaternion = SecondOrderTargetingQuaternion.new()

var meta_path_index: int = 0

func _ready() -> void:

	# Engine.time_scale = 0.1
	position_targeter.initialize(camera.global_position)

	# meta_paths[0].start_path_sequence()
	# meta_paths[4].start_path_sequence()

	var object_to_track = meta_paths[meta_path_index].path_sections[meta_paths[meta_path_index].section_index].object_to_track

	var look_direction = camera.global_position.direction_to(object_to_track.global_position).x
	x_look_targeter.initialize(look_direction)

	look_direction = camera.global_position.direction_to(object_to_track.global_position).y
	y_look_targeter.initialize(look_direction)

func _process(delta: float) -> void:
	camera.global_position = position_targeter.get_next_position(_get_current_target_position(), delta)

	var object_to_track = meta_paths[meta_path_index].path_sections[meta_paths[meta_path_index].section_index].object_to_track
	if object_to_track:
		var look_direction = camera.global_position.direction_to(object_to_track.global_position)

		camera.transform.basis = Basis()

		var target_x_angle = atan2(-look_direction.x, -look_direction.z)
		camera.rotate_object_local(Vector3.UP, x_look_targeter.get_next_position(target_x_angle, delta))

		# look_direction = camera.global_position.direction_to(object_to_track.global_position)

		var target_y_angle = atan2(look_direction.y, max(-look_direction.x, -look_direction.z))
		camera.rotate_object_local(Vector3.RIGHT, y_look_targeter.get_next_constrained_position(target_y_angle, delta))


func set_movement_target(index: int) -> void:
	if index >= 0 and index < meta_paths.size():
		print("Setting movement target to meta path index: " + str(index))
		meta_path_index = index

func _get_current_target_position() -> Vector3:
	return meta_paths[meta_path_index].get_target_location()

#region Input Handling
func _unhandled_input(event: InputEvent) -> void:
	var current_meta_path_index = meta_path_index
	if event.is_action_pressed("left"):
		current_meta_path_index = (current_meta_path_index - 1 + meta_paths.size()) % meta_paths.size()
		set_movement_target(current_meta_path_index)
	if event.is_action_pressed("right"):
		current_meta_path_index = (current_meta_path_index + 1) % meta_paths.size()
		set_movement_target(current_meta_path_index)
#endregion
