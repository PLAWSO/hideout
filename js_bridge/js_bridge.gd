extends Node

var console
var canvas_width: float
var canvas_height: float

func _ready() -> void:
	console = JavaScriptBridge.get_interface("window")

func _process(_delta: float) -> void:
	if console:
		canvas_width = console.getCanvasWidth()
		canvas_height = console.getCanvasHeight()

func setWatchedIntro() -> void:
	if console:
		console.setWatchedIntro()

func hasWatchedIntro() -> bool:
	if console:
		return console.hasWatchedIntro()

	return true
