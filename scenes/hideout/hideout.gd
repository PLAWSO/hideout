extends Node3D

@export var cinna_cam: CinnaCam
@export var transition: ColorRect
@export var skip_dialogue: bool = true

@onready var test_balloon: CanvasLayer = $TestBalloon

var movement_buttons: Array[Button] = []
var back_button: Button
var last_show_all_buttons: bool = true


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
	var v_box_children = $TouchInput/CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer.get_children()
	for child in v_box_children:
		if child is Button:
			if child.text != "":
				movement_buttons.append(child)
				continue
			back_button = child

	if skip_dialogue:
		cinna_cam.camera.current = true
		return

	switch_visible_movement_buttons(true)

	Events.skipped_intro.connect(_on_skipped_intro)
	Events.switch_visible_movement_buttons.connect(switch_visible_buttons_if_obscured)

	Events.arrived_at_meta_path.connect(_show_last_visible_movement_buttons)
	Events.left_meta_path.connect(_show_all_movement_buttons)

	await get_tree().create_timer(1.0).timeout
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon_scene(test_balloon, load("res://dialog/test.dialogue"), "start")


func _on_skipped_intro() -> void:
	test_balloon.queue_free()
	transition_to_drone()













# need to rename these functions/signals for clarity
var has_arrived_at_4: bool = false

func switch_visible_movement_buttons(show_all_buttons: bool) -> void:
	if show_all_buttons:
		for button in movement_buttons:
			button.visible = true
		back_button.visible = false
	else:
		for button in movement_buttons:
			button.visible = false
		back_button.visible = true


func switch_visible_buttons_if_obscured(show_all_buttons: bool) -> void:
	last_show_all_buttons = show_all_buttons
	print("Cinna Cam Meta Path Index: " + str(cinna_cam.meta_path_index))
	if not has_arrived_at_4:
		return
	print("Switching visible movement buttons to: " + str(show_all_buttons))
	switch_visible_movement_buttons(show_all_buttons)


func _show_last_visible_movement_buttons(_meta_path_index: int) -> void:
	if cinna_cam.meta_path_index != 4:
		return
	has_arrived_at_4 = true
	print("Restoring last visible movement buttons: " + str(last_show_all_buttons))
	switch_visible_movement_buttons(last_show_all_buttons)


func _show_all_movement_buttons(_meta_path_index: int) -> void:
	has_arrived_at_4 = false
	print("Showing all movement buttons")
	switch_visible_movement_buttons(true)










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


func _on_back_button_pressed() -> void:
	cinna_cam.set_movement_target(0)
