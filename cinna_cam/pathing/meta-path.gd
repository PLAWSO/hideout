@tool
class_name MetaPath extends Node3D

#region Properties

@export_tool_button("Make Continuous", "VisualShaderNodeCurveXYZTexture") var make_continuous_action = make_continuous
@export_range(0, 1, 0.01) var crossfade_time: float = 0.01
@export var is_looped: bool = true

var path_sections: Array[PathSection] = []
var section_index: int = 0

var tween: Tween = null

#endregion

#region Curve Change Handling

func make_continuous():
	collect_path_sections()

	var last_valid_start_point = path_sections[0].global_position
	var last_section_was_zero_length = false
	for i in range(path_sections.size()):
		print("Adjusting PathSection ", i)
		var current_section = path_sections[i % path_sections.size()]
		var next_section = path_sections[(i + 1) % path_sections.size()]

		if current_section.zero_length:
			current_section.global_position = last_valid_start_point
			last_section_was_zero_length = true
			if is_looped and i == path_sections.size() - 1:
				print("Looping back to first section for zero-length adjustment.")
				var next_next_section = path_sections[(i + 2) % path_sections.size()]
				next_section.global_position = last_valid_start_point
				next_section.curve.set_point_position(next_section.curve.get_point_count() - 1, next_section.to_local(next_next_section.global_position))
			continue
		
		if last_section_was_zero_length:
			current_section.global_position = last_valid_start_point
			last_section_was_zero_length = false
		
		last_valid_start_point = next_section.global_position

		if not is_looped and i == path_sections.size() - 1:
			continue
		
		var new_local_end_point = current_section.to_local(last_valid_start_point)
		current_section.curve.set_point_position(current_section.curve.get_point_count() - 1, new_local_end_point)

#endregion

#region Lifecycle

func _ready() -> void:
	collect_path_sections()

func collect_path_sections() -> void:
	path_sections.clear()
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
		var target_y_angle = asin(look_direction.y)

		return Vector2(target_x_angle, target_y_angle)

	if path_section.tracking_type == PathSection.TrackingType.LOCK_AT_PREVIOUS:
		var previous_index = section_index - 1 % path_sections.size()

		var previous_section = path_sections[previous_index]
		var object_to_track = previous_section.follow_target
		
		if object_to_track == null:
			return Vector2.ZERO
		
		var look_direction = path_section.global_position.direction_to(object_to_track.global_position)
		var target_x_angle = atan2(-look_direction.x, -look_direction.z)
		var target_y_angle = asin(look_direction.y)


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
		var timer = get_tree().create_timer(section.time_to_finish - crossfade_time)
		timer.connect("timeout", Callable(self, "_on_section_complete"))
		# tween.tween_callback(_on_section_complete).set_delay(1e-6)
	else:
		var timer = get_tree().create_timer(section.time_to_finish)
		timer.connect("timeout", Callable(self, "_on_section_complete"))


func _on_section_complete() -> void:
	# print("Section ", section_index, " complete.")
	_move_to_next_section()
	_start_section_movement()

#endregion
