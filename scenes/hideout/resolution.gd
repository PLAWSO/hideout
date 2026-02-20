extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var resolution = get_viewport().get_visible_rect().size
	text = str("Resolution: " + str(resolution.x) + "x" + str(resolution.y))
