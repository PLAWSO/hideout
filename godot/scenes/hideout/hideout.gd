extends Node3D

@export var cinna_cam: CinnaCam
@export var transition: ColorRect

@onready var dialogue_container: CanvasLayer = $GUI/DialogueContainer

@onready var void_calibur := $SubViewport/ArcadeGame

@onready var focus_holder := $GUI/FocusHolder

func _unhandled_input(event: InputEvent) -> void:
	if cinna_cam.meta_path_index == 2:
		void_calibur.input(event)


#region Lifecycle

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	Events.arrived_at_meta_path.connect(_on_arrived_at_meta_path)

	var has_watched_intro = JSBridge.get_watched_intro()
	_start_intro_sequence(has_watched_intro)


func _physics_process(delta: float) -> void:
	JSBridge.get_set_javascript_canvas_size()
	JSBridge.get_set_viewport_size()
	cinna_cam.run(delta)

#endregion

#region Introduction

func _start_intro_sequence(has_watched_intro: bool) -> void:
	if has_watched_intro:
		DialogueManager.show_dialogue_balloon_scene(dialogue_container, load("res://dialog/trees/welcome_back.dialogue"), "start")
		return

	DialogueManager.show_dialogue_balloon_scene(dialogue_container, load("res://dialog/trees/intro.dialogue"), "start")


func _on_dialogue_ended(_resource) -> void:
	_transition_to_drone()
	JSBridge.set_watched_intro()


func _transition_to_drone() -> void:
	cinna_cam.camera.current = true
	transition.visible = true
	var tween = create_tween()
	tween.tween_property(transition.material, "shader_parameter/opacity", 0.0, 3.0).from(1.0)

#endregion

func _on_arrived_at_meta_path(_meta_path_index: int) -> void:
	if _meta_path_index == 2:
		focus_holder.grab_focus()
	pass
