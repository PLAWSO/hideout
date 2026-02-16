extends Node3D

@export var cinna_cam: CinnaCam
@export var transition: ColorRect

@onready var test_balloon: CanvasLayer = $TestBalloon

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


func _ready() -> void:
	# DialogueManager.show_dialogue_balloon_scene()
	await get_tree().create_timer(1.0).timeout
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon_scene(test_balloon, load("res://dialog/test.dialogue"), "start")
	pass

func _on_dialogue_ended(resource) -> void:
	print(cinna_cam)
	cinna_cam.camera.current = true
	transition.visible = true
	var tween = create_tween()
	# Tween the shader's opacity parameter from 1.0 (opaque) to 0.0 (transparent)
	tween.tween_property(transition.material, "shader_parameter/opacity", 0.0, 3.0).from(1.0)
	
	
# 	var resource = load("res://dialog/test.dialogue")
# 	var firstLine = await resource.get_next_dialogue_line("start")
# 	dialog_test.dialogue_label = firstLine
