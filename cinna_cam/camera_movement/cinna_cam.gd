@tool
@icon("res://icons/camera_controller_icon.svg")
class_name CinnaCam extends Node3D

#region Properties

@export var camera: Node3D
@export var meta_paths: Array[MetaPath] = []

@export var position_targeter: PlanarSystem = PlanarSystem.new()
@export var x_look_targeter: AngularSystem = AngularSystem.new()
@export var y_look_targeter: AngularSystem = AngularSystem.new()

var meta_path_index: int = 0

signal jump_cut(from_meta_path_index: int)


func initialize(path_index) -> void:
	position_targeter.initialize(camera.global_position)

	var initial_angle = meta_paths[path_index].get_target_angles(camera.global_position)
	x_look_targeter.initialize(initial_angle.x)
	y_look_targeter.initialize(initial_angle.y)

#endregion

#region Lifecycle

func _ready() -> void:
	Engine.time_scale = 1.0
	if not camera:
		return
	
	initialize(0)

	jump_cut.connect(try_jump_cut)
	
	for meta_path in meta_paths:
		if meta_path.auto_start:
			meta_path.start_path_sequence()
			meta_path.jump_cut_signal = jump_cut
			meta_path.meta_path_index = meta_path_index

func _physics_process(delta: float) -> void:
	if not camera:
		return
	move_camera(delta)
	rotate_camera(delta)

	# for meta_path in meta_paths:
	# 	meta_path.move_preview_mesh_to_current_target(delta, x_look_targeter, y_look_targeter)

#endregion

#region Methods

func move_camera(delta: float) -> void:
	var current_target_pos = meta_paths[meta_path_index].get_target_location()
	var new_camera_pos = position_targeter.get_next_position(current_target_pos, delta)
	camera.global_position = new_camera_pos

func rotate_camera(delta: float) -> void:
	# DebugDraw2D.set_text("camera_angle", camera.rotation, 0, Color.WHITE)
	var new_camera_rotation = meta_paths[meta_path_index].get_target_angles(camera.global_position)
	camera.transform.basis = Basis()
	camera.rotate_object_local(Vector3.UP, x_look_targeter.get_next_angle(new_camera_rotation.x, delta))
	camera.rotate_object_local(Vector3.RIGHT, y_look_targeter.get_next_constrained_angle(new_camera_rotation.y, delta))

func set_movement_target(index: int) -> void:
	if index >= 0 and index < meta_paths.size():
		# print("Setting movement target to meta path index: " + str(index))
		meta_path_index = index

func try_jump_cut(from_meta_path_index: int) -> void:
	if from_meta_path_index != meta_path_index:
		return
	var new_target_pos = meta_paths[meta_path_index].get_target_location()
	position_targeter.initialize(new_target_pos)
	camera.global_position = new_target_pos
	# DebugDraw2D.set_text("camera_angle", camera.rotation, 0, Color.WHITE)

	var new_camera_rotation = meta_paths[meta_path_index].get_target_angles(camera.global_position)
	x_look_targeter.initialize(new_camera_rotation.x)
	y_look_targeter.initialize(new_camera_rotation.y)
	
	camera.basis = Basis()
	camera.rotate_object_local(Vector3.UP, new_camera_rotation.x)
	camera.rotate_object_local(Vector3.RIGHT, new_camera_rotation.y)


#endregion
