extends Node

var console
var json_interface

var canvas_size: Vector2
var viewport_size: Vector2
var terminal_bounds: Rect2

var percentiles: Array[KeyIntPair]
var top_runs: Array[KeyIntPair]

var _set_top_scores_callback_ref = JavaScriptBridge.create_callback(_set_top_scores_from_db)
var percentile_names = ["10%", "20%", "30%", "40%", "50%", "60%", "70%", "75%", "80%", "85%", "90%", "95%", "96%", "97%", "98%", "99%"]


@export var terminal: Node3D

func _ready() -> void:
	console = JavaScriptBridge.get_interface("window")
	json_interface = JavaScriptBridge.get_interface("JSON")

	if console:
		console.sendTopScoresToGodot = _set_top_scores_callback_ref


func get_set_javascript_canvas_size() -> void:
	if console:
		canvas_size = Vector2(console.getCanvasWidth(), console.getCanvasHeight())


func get_set_viewport_size() -> void:
	viewport_size = get_viewport().get_visible_rect().size


func set_terminal_bounds(rect: Rect2) -> void:
	terminal_bounds = rect
	console.setTerminalBounds(rect.position.x, rect.position.y, rect.size.x, rect.size.y)

func show_rotate_device_icon(show: bool) -> void:
	if console:
		console.showRotateDeviceIcon(show)


func set_watched_intro() -> void:
	if console:
		console.setWatchedIntro()


func get_watched_intro() -> bool:
	if console:
		return console.getWatchedIntro()

	return true


func get_username() -> String:
	if console:
		return console.getUsername()

	return ""


func set_terminal_gui_visible(visible: bool) -> void:
	if console:
		console.setTerminalGUIVisible(visible)

func set_player_visible(visible: bool) -> void:
	if console:
		console.setPlayerVisible(visible)


func save_score(score: int) -> bool:
	if console:
		console.saveScore(score)
		return true
	return false


var could_not_parse_error := "error parsing top scores" 

func _set_top_scores_from_db(args) -> void:
	if args.is_empty():
		return

	if not (args[0] is JavaScriptObject):
		print(could_not_parse_error)
		return

	var args_parsed = JSON.parse_string(json_interface.stringify(args[0]))

	if not (args_parsed is Array) or args_parsed.size() != 2:
		print(could_not_parse_error)
		return

	var unparsed_percentiles = args_parsed[0]

	if not (unparsed_percentiles is Array) or not (unparsed_percentiles.size() == 16):
		print(could_not_parse_error)
		return

	for i in range(unparsed_percentiles.size()):
		if not (unparsed_percentiles[i] is float):
			print(could_not_parse_error)
			return
		
		var percentile = KeyIntPair.new(int(unparsed_percentiles[i]), percentile_names[i])
		percentiles.append(percentile)

	var unparsed_top_runs = args_parsed[1]

	if not (unparsed_top_runs is Array) or not (unparsed_top_runs.size() == 10):
		print(could_not_parse_error)
		return
	
	for i in range(unparsed_top_runs.size()):
		var run = unparsed_top_runs[i]
		
		if not (run is Dictionary):
			print(could_not_parse_error)
			return

		if not (run.has("score") and run.has("username")):
			print(could_not_parse_error)
			return

		var score = run["score"]
		var username = run["username"]
		
		if not (score is float and username is String):
			print(could_not_parse_error)
			return
		
		var run_pair = KeyIntPair.new(int(score), username)
		top_runs.append(run_pair)

	print("successfully parsed top scores from db")
	Events.scores_received.emit()

func check_set_personal_best(score: int) -> bool:
	if console:
		return console.checkSetPersonalBest(score)
	return false

func get_personal_best() -> int:
	if console:
		return console.getPersonalBest()
	return 0