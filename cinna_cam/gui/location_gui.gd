extends Control

@export var cinna_cam: CinnaCam
@export var obstacle: Node3D

@onready var blocker = $CanvasLayer/Control/MarginContainer/Blocker
@onready var back_button_icon = preload("res://themes/left-arrow-back.svg")

var back_button: Button
var movement_buttons: Array[Button] = []
var last_show_all_buttons: bool = true
var show_all_buttons: bool = true
var has_arrived_at_4: bool = false


#region Lifecycle

func _ready() -> void:
	blocker.visible = true

	var v_box_children = $CanvasLayer/Control/MarginContainer/MarginContainer/VBoxContainer.get_children()
	for child in v_box_children:
		if child is Button:
			if child.text != "Loiter":
				movement_buttons.append(child)
				continue
			back_button = child
	
	switch_visible_movement_buttons(true)

	Events.safe_zone_crossed.connect(switch_visible_buttons_if_obscured)

	Events.arrived_at_meta_path.connect(_on_arrived_at_meta_path)
	Events.left_meta_path.connect(_on_left_meta_path)
	Events.camera_moved.connect(_on_camera_moved)
	DialogueManager.dialogue_ended.connect(_enable_movement_buttons)

#endregion

func _on_camera_moved() -> void:
	set_terminal_bounds()
	check_safe_zone_crossed()


func _enable_movement_buttons(_resource) -> void:
	blocker.visible = false


func set_terminal_bounds() -> void:
	if JSBridge.console:
		var obstacle_bounds = obstacle.get_bounds()

		var scale_x = JSBridge.canvas_size.x / JSBridge.viewport_size.x
		var scale_y = JSBridge.canvas_size.y / JSBridge.viewport_size.y

		var left = obstacle_bounds.position.x * scale_x
		var top = obstacle_bounds.position.y * scale_y
		var width = obstacle_bounds.size.x * scale_x
		var height = obstacle_bounds.size.y * scale_y

		JSBridge.set_terminal_bounds(Rect2(left, top, width, height))


func check_safe_zone_crossed() -> void:
	if show_all_buttons and (JSBridge.terminal_bounds.position.x < 270.0 * JSBridge.canvas_size.x / JSBridge.viewport_size.x):
		Events.safe_zone_crossed.emit(false)
		show_all_buttons = false
	elif not show_all_buttons and (JSBridge.terminal_bounds.position.x >= 270.0 * JSBridge.canvas_size.x / JSBridge.viewport_size.x):
		Events.safe_zone_crossed.emit(true)
		show_all_buttons = true


func switch_visible_movement_buttons(show_buttons: bool) -> void:
	if show_buttons:
		for button in movement_buttons:
			button.visible = true
		back_button.icon = null
		back_button.text = "Loiter"
		back_button.custom_minimum_size = Vector2(250, 60)
	else:
		for button in movement_buttons:
			button.visible = false
		back_button.icon = back_button_icon
		back_button.text = ""
		back_button.custom_minimum_size = Vector2(50, 50)


func switch_visible_buttons_if_obscured(show_buttons: bool) -> void:
	last_show_all_buttons = show_buttons
	if not has_arrived_at_4:
		return
	switch_visible_movement_buttons(show_buttons)


func _on_arrived_at_meta_path(_meta_path_index: int) -> void:
	if cinna_cam.meta_path_index != 4:
		return
	has_arrived_at_4 = true
	switch_visible_movement_buttons(last_show_all_buttons)


func _on_left_meta_path(_meta_path_index: int) -> void:
	has_arrived_at_4 = false
	switch_visible_movement_buttons(true)


func _on_loiter_button_pressed() -> void:
	cinna_cam.set_movement_target(0)


func _on_back_button_pressed() -> void:
	cinna_cam.set_movement_target(0)


func _on_bike_button_pressed() -> void:
	cinna_cam.set_movement_target(1)


func _on_arcade_button_pressed() -> void:
	cinna_cam.set_movement_target(2)


func _on_toolbox_button_pressed() -> void:
	cinna_cam.set_movement_target(3)


func _on_terminal_button_pressed() -> void:
	cinna_cam.set_movement_target(4)