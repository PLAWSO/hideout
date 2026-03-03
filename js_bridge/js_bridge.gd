extends Node

var console
var canvas_size: Vector2

var viewport_size: Vector2

var terminal_bounds: Rect2

func _ready() -> void:
	console = JavaScriptBridge.get_interface("window")

func setCanvasDimensions() -> void:
	if console:
		canvas_size = Vector2(console.getCanvasWidth(), console.getCanvasHeight())

func setViewportDimensions(size: Vector2) -> void:
	viewport_size = size

func setTerminalBounds(size: Rect2) -> void:
	terminal_bounds = size
	
func setWatchedIntro() -> void:
	if console:
		console.setWatchedIntro()

func hasWatchedIntro() -> bool:
	if console:
		return console.hasWatchedIntro()

	return true
