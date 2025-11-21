extends Node3D

@export var cinna_cam: CinnaCam

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


func _on_next_camera_pressed() -> void:
	cinna_cam.set_movement_target((cinna_cam.meta_path_index + 1) % cinna_cam.meta_paths.size())
	pass # Replace with function body.

func _on_previous_camera_pressed() -> void:
	cinna_cam.set_movement_target((cinna_cam.meta_path_index - 1 + cinna_cam.meta_paths.size()) % cinna_cam.meta_paths.size())
	pass # Replace with function body.
