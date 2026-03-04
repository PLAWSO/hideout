extends Node

var console
var canvas_size: Vector2

var viewport_size: Vector2

var terminal_bounds: Rect2

@export var terminal: Node3D

func _ready() -> void:
	console = JavaScriptBridge.get_interface("window")


func get_set_javascript_canvas_size() -> void:
	if console:
		canvas_size = Vector2(console.getCanvasWidth(), console.getCanvasHeight())


func get_set_viewport_size() -> void:
	viewport_size = get_viewport().get_visible_rect().size


func set_terminal_bounds(rect: Rect2) -> void:
	terminal_bounds = rect
	console.setTerminalBounds(rect.position.x, rect.position.y, rect.size.x, rect.size.y)


func set_watched_intro() -> void:
	if console:
		console.setWatchedIntro()


func get_watched_intro() -> bool:
	if console:
		return console.getWatchedIntro()

	return true


func set_terminal_gui_visible(visible: bool) -> void:
	if console:
		console.setTerminalGUIVisible(visible)
