@icon("res://icons/camera_controller_icon.svg")
class_name CinnaCam extends Node3D

@export var camera: Camera3D
@export var meta_paths: Array[MetaPath] = []

@export var position_targeter: PlanarSystem = PlanarSystem.new()
@export var x_look_targeter: AngularSystem = AngularSystem.new()
@export var y_look_targeter: AngularSystem = AngularSystem.new()

var meta_path_index: int = 0

func _ready() -> void:
	# Engine.time_scale = 0.1
	initialize(0, 0)


func initialize(path_index, section_index) -> void:
	position_targeter.initialize(camera.global_position)

	var object_to_track = meta_paths[path_index].path_sections[section_index].object_to_track

	var look_direction = camera.global_position.direction_to(object_to_track.global_position).x
	x_look_targeter.initialize(look_direction)

	look_direction = camera.global_position.direction_to(object_to_track.global_position).y
	y_look_targeter.initialize(look_direction)


func _process(delta: float) -> void:
	move_camera(delta)
	rotate_camera(delta)


func move_camera(delta: float) -> void:
	var current_target_pos = meta_paths[meta_path_index].get_target_location()
	var new_camera_pos = position_targeter.get_next_position(current_target_pos, delta)
	camera.global_position = new_camera_pos


func rotate_camera(delta: float) -> void:
	var object_to_track = meta_paths[meta_path_index].path_sections[meta_paths[meta_path_index].section_index].object_to_track
	if object_to_track:
		var look_direction = camera.global_position.direction_to(object_to_track.global_position)

		camera.transform.basis = Basis()

		var target_x_angle = atan2(-look_direction.x, -look_direction.z)
		camera.rotate_object_local(Vector3.UP, x_look_targeter.get_next_position(target_x_angle, delta))

		var target_y_angle = atan2(look_direction.y, max(-look_direction.x, -look_direction.z))
		camera.rotate_object_local(Vector3.RIGHT, y_look_targeter.get_next_constrained_position(target_y_angle, delta))


func set_movement_target(index: int) -> void:
	if index >= 0 and index < meta_paths.size():
		print("Setting movement target to meta path index: " + str(index))
		meta_path_index = index
