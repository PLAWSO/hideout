extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var fps_label: Label = $CanvasLayer/VBoxContainer/FPSCounter
@onready var resolution_label: Label = $CanvasLayer/VBoxContainer/InternalResolution
@onready var canvas_size_label: Label = $CanvasLayer/VBoxContainer/CanvasSize

var _callback_ref = JavaScriptBridge.create_callback(_on_show_debug)

func _ready() -> void:
	canvas_layer.visible = false

	var console = JavaScriptBridge.get_interface("window")

	if console:
		console.onShowDebug = _callback_ref


func _process(_delta: float) -> void:
	update_fps_label()
	update_resolution_label()
	update_canvas_size_label()


func _on_show_debug(args):
	print("Received show debug signal from JavaScript with args: ", args)
	var show_debug = args[0]

	if show_debug:
		canvas_layer.visible = true
	else:
		canvas_layer.visible = false



func update_fps_label() -> void:
	var fps = Engine.get_frames_per_second()
	fps_label.text = str("FPS: " + str(fps))

func update_resolution_label() -> void:
	var resolution = get_viewport().get_visible_rect().size
	resolution_label.text = str("Internal Resolution: " + str(resolution.x) + "x" + str(resolution.y))

func update_canvas_size_label() -> void:
	var canvas_size = Vector2(JSBridge.canvas_width, JSBridge.canvas_height)
	canvas_size_label.text = str("Canvas Size: " + str(canvas_size.x) + "x" + str(canvas_size.y))
