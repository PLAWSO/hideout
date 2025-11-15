@tool
extends Node3D

@export var cinna_cam: CinnaCam = null
@export var camera: Node3D = null:
	get:
		return cinna_cam.camera
	set(value):
		cinna_cam.camera = value


func _on_cinna_cam_ready() -> void:
	cinna_cam.meta_paths[0].start_path_sequence()

