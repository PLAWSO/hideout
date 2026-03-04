extends Button


func _ready() -> void:
	if not JSBridge.hasWatchedIntro():
		visible = false
	pass



func _on_pressed() -> void:
	Events.skipped_intro.emit()
