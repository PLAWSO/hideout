extends Node3D

@export var cinna_cam: CinnaCam = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cinna_cam_ready() -> void:
	cinna_cam.meta_paths[0].start_path_sequence()

