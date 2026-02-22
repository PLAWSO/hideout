extends Node3D

@export var cinna_cam: CinnaCam
@export var transition: ColorRect
@export var skip_dialogue: bool = true

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

func _ready() -> void:
	if skip_dialogue:
		cinna_cam.camera.current = true
		return

	Events.skipped_intro.connect(_on_skipped_intro)

	await get_tree().create_timer(1.0).timeout
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon_scene(test_balloon, load("res://dialog/test.dialogue"), "start")

func _on_skipped_intro() -> void:
	test_balloon.queue_free()
	transition_to_drone()

func _on_dialogue_ended(_resource) -> void:
	transition_to_drone()
	JSBridge.setWatchedIntro()

func transition_to_drone() -> void:
	cinna_cam.camera.current = true
	transition.visible = true
	var tween = create_tween()
	tween.tween_property(transition.material, "shader_parameter/opacity", 0.0, 3.0).from(1.0)


func _on_arcade_button_pressed() -> void:
	cinna_cam.set_movement_target(2)

func _on_loiter_button_pressed() -> void:
	cinna_cam.set_movement_target(0)

func _on_toolbox_button_pressed() -> void:
	cinna_cam.set_movement_target(3)

func _on_bike_button_pressed() -> void:
	cinna_cam.set_movement_target(1)

func _on_terminal_button_pressed() -> void:
	cinna_cam.set_movement_target(4)
