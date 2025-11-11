class_name MetaPath extends Node

var path_sections: Array[PathSection] = []

var section_index: int = 0
var tween: Tween = null


func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is PathSection:
			path_sections.append(child)
		else:
			push_warning("MetaPath child is not a PathSection: " + str(child))
	
	if path_sections.size() == 0:
		push_error("No path sections defined in MetaPath.")


func get_target_location() -> Vector3:
	return path_sections[section_index].target.global_position


func start_path_sequence() -> void:
	section_index = 0
	_reset_path_sections()
	_start_section_movement()


func _move_to_next_section() -> void:

	section_index = (section_index + 1) % path_sections.size()
	if section_index == 0:
		_reset_path_sections()

func _reset_path_sections() -> void:
	for section in path_sections:
		if !section.zero_length:
			section.target.progress_ratio = 0.0


func _start_section_movement() -> void: 
	if tween:
		tween.kill()

	var section = path_sections[section_index]

	if !section.zero_length:
		tween = create_tween()
		tween.tween_property(section.target, "progress_ratio", 1, section.time_to_finish)
		tween.tween_callback(_on_section_complete).set_delay(0.001)
	else:
		var timer = get_tree().create_timer(section.time_to_finish)
		timer.connect("timeout", Callable(self, "_on_section_complete"))

func _on_section_complete() -> void:
	print("Section ", section_index, " complete.")
	_move_to_next_section()
	_start_section_movement()
