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

	var initial_angle = meta_paths[path_index].get_target_angles(camera.global_position)
	x_look_targeter.initialize(initial_angle.x)
	y_look_targeter.initialize(initial_angle.y)


func _process(delta: float) -> void:
	move_camera(delta)
	rotate_camera(delta)


func move_camera(delta: float) -> void:
	var current_target_pos = meta_paths[meta_path_index].get_target_location()
	var new_camera_pos = position_targeter.get_next_position(current_target_pos, delta)
	camera.global_position = new_camera_pos


func rotate_camera(delta: float) -> void:
	var new_camera_rotation = meta_paths[meta_path_index].get_target_angles(camera.global_position)
	
	camera.transform.basis = Basis()
	camera.rotate_object_local(Vector3.UP, x_look_targeter.get_next_position(new_camera_rotation.x, delta))
	camera.rotate_object_local(Vector3.RIGHT, y_look_targeter.get_next_constrained_position(new_camera_rotation.y, delta))


func set_movement_target(index: int) -> void:
	if index >= 0 and index < meta_paths.size():
		print("Setting movement target to meta path index: " + str(index))
		meta_path_index = index
