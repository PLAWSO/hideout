@tool
extends Node3D

@export var cinna_cam: CinnaCam = null

@export_group("Visibility")
@export var hideCeiling: bool = false
@export var hideProps: bool = false
@export var hideWalls: bool = false

func _set_floor_visibility() -> void:
	$Ceiling.visible = !hideCeiling
	$Props.visible = !hideProps
	$Walls.visible = !hideWalls

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_set_floor_visibility()
	pass

func _on_camera_controller_ready() -> void:
	cinna_cam.meta_paths[2].start_path_sequence()

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

# 	meta_paths[0].start_path_sequence()
# 	# meta_paths[3].start_path_sequence()

# if OS.has_feature("web"): # Check if running in a web environment
# 	JavaScriptBridge.eval("console.log('Hello from Godot in JavaScript!');thisIsATest();")

	# if OS.has_feature("web"): # Check if running in a web environment
	# 	if index == 4:
	# 		JavaScriptBridge.eval("showVideo(true);")
	# 	else:
	# 		JavaScriptBridge.eval("showVideo(false);")
