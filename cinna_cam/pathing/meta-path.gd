@tool
class_name MetaPath extends Node

#region Properties

@export_tool_button("Make Continuous", "VisualShaderNodeCurveXYZTexture") var make_continuous_action = make_continuous
@export var is_looped: bool = true

var path_sections: Array[PathSection] = []
var section_index: int = 0

var tween: Tween = null


#region Curve Change Handling

func make_continuous():
	for i in range(path_sections.size() if is_looped else path_sections.size() - 1):
		var current_section = path_sections[i]
		var next_section = path_sections[(i + 1) % path_sections.size()]

		var end_point = current_section.curve.get_point_position(current_section.curve.get_point_count() - 1)
		var global_end_point = current_section.to_global(end_point)

		var local_start_point = next_section.to_local(global_end_point)

		next_section.curve.set_point_position(0, local_start_point)

#endregion

#region Lifecycle

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is PathSection:
			path_sections.append(child)
		else:
			push_warning("MetaPath child is not a PathSection: " + str(child))

	if path_sections.size() == 0:
		push_error("No path sections defined in MetaPath.")

#endregion

#region Target Retrieval

func get_target_location() -> Vector3:
	return path_sections[section_index].target.global_position


func get_target_angles(origin: Vector3) -> Vector2:
	var path_section = path_sections[section_index]

	if path_section.tracking_type == PathSection.TrackingType.ANGLE:
		var path_length = path_section.curve.get_baked_length()
		var target_x_angle = 0.0
		if path_section.relative_to_travel_direction:
			var rear_point = path_section.curve.sample_baked((path_section.target.progress_ratio - 0.005) * path_length, true) + path_section.global_position
			var front_point = path_section.curve.sample_baked((path_section.target.progress_ratio + 0.005) * path_length, true) + path_section.global_position
			var travel_direction = rear_point.direction_to(front_point)
			target_x_angle = atan2(-travel_direction.x, -travel_direction.z)

		return Vector2(target_x_angle + path_section.angle_target.x, path_section.angle_target.y)

	if path_section.tracking_type == PathSection.TrackingType.FOLLOW:
		var object_to_track = path_section.follow_target
		if object_to_track == null:
			return Vector2.ZERO
		var look_direction = origin.direction_to(object_to_track.global_position)
		var target_x_angle = atan2(-look_direction.x, -look_direction.z)
		var target_y_angle = atan2(look_direction.y, max(-look_direction.x, -look_direction.z))
		return Vector2(target_x_angle, target_y_angle)

	return Vector2.ZERO

#endregion

#region Path Movement Control

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
	# print("Section ", section_index, " complete.")
	_move_to_next_section()
	_start_section_movement()

#endregion
