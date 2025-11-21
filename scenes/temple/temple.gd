@tool
extends Node3D

@export var cinna_cam: CinnaCam = null
@export var camera: Node3D = null:
	get:
		return cinna_cam.camera
	set(value):
		cinna_cam.camera = value

