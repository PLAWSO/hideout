extends Node3D

@export var cinna_cam: CinnaCam

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_camera_controller_ready() -> void:
	cinna_cam.meta_paths[0].start_path_sequence()

#region Input Handling
func _unhandled_input(event: InputEvent) -> void:
	var current_meta_path_index = cinna_cam.meta_path_index
	var meta_path_count = cinna_cam.meta_paths.size()
	if event.is_action_pressed("left"):
		current_meta_path_index = (current_meta_path_index - 1 + meta_path_count) % meta_path_count
		cinna_cam.set_movement_target(current_meta_path_index)
	if event.is_action_pressed("right"):
		current_meta_path_index = (current_meta_path_index + 1) % meta_path_count
		cinna_cam.set_movement_target(current_meta_path_index)
#endregion