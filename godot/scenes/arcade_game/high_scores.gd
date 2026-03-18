extends Control

@export var first_place_label: Label
@export var second_place_label: Label
@export var third_place_label: Label
@export var fourth_place_label: Label
@export var fifth_place_label: Label
@export var sixth_place_label: Label
@export var seventh_place_label: Label
@export var eighth_place_label: Label
@export var ninth_place_label: Label

var score_labels: Array[Label]

var local_high_scores: Array[KeyIntPair] = []
var local_percentiles: Array[KeyIntPair] = []

var high_score_flasher: Tween
var flashing := 0

func _ready() -> void:
	score_labels = [
		first_place_label,
		second_place_label,
		third_place_label,
		fourth_place_label,
		fifth_place_label,
		sixth_place_label,
		seventh_place_label,
		eighth_place_label,
		ninth_place_label
	]

	Events.scores_received.connect(_on_scores_received)
	Events.game_reset.connect(_on_game_reset)

func _fill_high_scores() -> void:
	for i in range(score_labels.size()):
		var run = local_high_scores[i]
		score_labels[i].text = str(run.value) + " " + run.key


func _flash_new_score(index: int) -> void:
	var label = score_labels[index]
	high_score_flasher = create_tween().set_loops()
	high_score_flasher.tween_property(label, "theme_override_colors/font_color", Color(0, 0, 0, 1), 0.5)
	high_score_flasher.tween_property(label, "theme_override_colors/font_color", Color(1, 1, 1, 1), 0.5)
	flashing = index


func _on_scores_received() -> void:
	local_high_scores = JSBridge.top_runs
	local_percentiles = JSBridge.percentiles

	_fill_high_scores()


func _on_game_reset() -> void:
	if high_score_flasher:
		high_score_flasher.kill()
		score_labels[flashing].add_theme_color_override("font_color", Color(1, 1, 1, 1))


func check_add_high_score(score: int) -> String:
	if not local_high_scores or not local_percentiles:
		return "populate high scores to see stats :D"

	for i in range(local_high_scores.size() - 1):
		if score > local_high_scores[i].value:
			var username = JSBridge.get_username()
			local_high_scores.insert(i, KeyIntPair.new(score, username))
			local_high_scores.pop_back()
			_fill_high_scores()
			_flash_new_score(i)
			return "!! NEW HIGH SCORE !!"
	
	if score < local_percentiles[0].value:
		return "erm... maybe try again :)"
	
	for i in range(1, local_percentiles.size()):
		if score < local_percentiles[i].value:
			return "better than %s of all attempts!" % local_percentiles[i - 1].key
	
	return "something went wrong"
