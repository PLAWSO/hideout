@tool
class_name MetaPath extends Node3D

#region Properties

@export_tool_button("Make Continuous", "VisualShaderNodeCurveXYZTexture") var make_continuous_action = make_continuous
@export_range(0, 1, 0.01) var crossfade_time: float = 0.01
@export var is_looped: bool = true
@export var auto_start: bool = false:
	set(value):
		auto_start = value
		if not self.is_node_ready():
			return
		if Engine.is_editor_hint():
			if auto_start:
				start_path_sequence()
			else:
				stop_path_sequence()
			notify_property_list_changed()

var path_sections: Array[PathSection] = []
var section_index: int = 0
var running: bool = false

var tween: Tween = null
var timer: Timer = null

var jump_cut_signal

var meta_path_index: int

# @onready var preview_mesh: Node3D = $PreviewMesh
@export var preview_mesh: Node3D
@export var show_preview_mesh: bool = true:
	set(value):
		show_preview_mesh = value
		if preview_mesh:
			preview_mesh.visible = show_preview_mesh

#endregion

#region Lifecycle

func _ready() -> void:
	collect_path_sections()

	if not Engine.is_editor_hint() and preview_mesh:
		preview_mesh.visible = show_preview_mesh

	if not Engine.is_editor_hint() and auto_start:
		start_path_sequence()

func collect_path_sections() -> void:
	path_sections.clear()
	var children = get_children()
	for child in children:
		if child is PathSection:
			path_sections.append(child)

	if path_sections.size() == 0:
		push_error("No path sections defined in MetaPath.")

#endregion

#region Curve Change Handling

func make_continuous():
	collect_path_sections()

	var last_valid_start_point = path_sections[0].global_position
	var last_section_was_zero_length = false
	for i in range(path_sections.size()):
		var current_section = path_sections[i % path_sections.size()]
		var next_section = path_sections[(i + 1) % path_sections.size()]

		if current_section.zero_length:
			current_section.global_position = last_valid_start_point
			last_section_was_zero_length = true
			if is_looped and i == path_sections.size() - 1:
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

#region Target Retrieval

# func move_preview_mesh_to_current_target(delta: float, x_look_targeter: AngularSystem, y_look_targeter: AngularSystem) -> void:
# 	if preview_mesh and path_sections.size() > 0:
# 		preview_mesh.global_position = get_target_location()
# 		var new_camera_rotation = get_target_angles(preview_mesh.global_position)
# 		preview_mesh.transform.basis = Basis()
# 		preview_mesh.rotate_object_local(Vector3.UP, x_look_targeter.get_next_angle(new_camera_rotation.x, delta))
# 		preview_mesh.rotate_object_local(Vector3.RIGHT, y_look_targeter.get_next_constrained_angle(new_camera_rotation.y, delta))

func get_target_location() -> Vector3:
	return path_sections[section_index].target.global_position


func get_target_angles(origin: Vector3) -> Vector2:
	var path_section = path_sections[section_index]

	if path_section.tracking_type == PathSection.TrackingType.ANGLE:
		var path_length = path_section.curve.get_baked_length()

		if path_section.relative_to_travel_direction:
			var rear_point = path_section.curve.sample_baked(max(.0, (path_section.target.progress_ratio - 0.005)) * path_length, true) + path_section.global_transform.origin
			var front_point = path_section.curve.sample_baked(min(1.0, (path_section.target.progress_ratio + 0.005)) * path_length, true) + path_section.global_transform.origin
			# DebugDraw2D.set_text("rear_point", rear_point - path_section.global_position, 0, Color.RED)
			# DebugDraw2D.set_text("front_point", front_point - path_section.global_position, 0, Color.RED)
			var travel_direction = rear_point.direction_to(front_point)
			var target_x_angle = atan2(-travel_direction.x, -travel_direction.z)
			return Vector2(target_x_angle + path_section.angle_target.x, path_section.angle_target.y)

		if path_section.treat_as_point:
			var target_direction = Vector3(
				-sin(path_section.angle_target.x),
				sin(path_section.angle_target.y),
				-cos(path_section.angle_target.x)
			).normalized()
			
			var offset_distance = 1.0
			var look_at_point = path_section.global_position + (target_direction * offset_distance)
			
			var look_direction = origin.direction_to(look_at_point)
			var target_x_angle = atan2(-look_direction.x, -look_direction.z)
			var target_y_angle = asin(look_direction.y)
			
			return Vector2(target_x_angle, target_y_angle)

		return Vector2(path_section.angle_target.x, path_section.angle_target.y)

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
	running = true
	section_index = 0
	_reset_path_sections()
	_start_section_movement()

func stop_path_sequence() -> void:
	running = false
	_reset_path_sections()
	_kill_timers()

func _move_to_next_section() -> void:
	var old_section_index = section_index
	section_index = (section_index + 1) % path_sections.size()

	if section_index == 0:
		_reset_path_sections()

	if path_sections[old_section_index].jump_cut_to_next:
		jump_cut_signal.emit(meta_path_index)

func _reset_path_sections() -> void:
	for section in path_sections:
		if !section.zero_length:
			section.target.progress_ratio = 0.0


func _start_section_movement() -> void:
	_kill_timers()

	var section = path_sections[section_index]

	if !section.zero_length:
		tween = create_tween()
		tween.tween_property(section.target, "progress_ratio", 1, section.time_to_finish)

	timer = Timer.new()
	timer.wait_time = section.time_to_finish
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.connect("timeout", Callable(self, "_on_section_complete"))

func _kill_timers() -> void:
	if timer:
		timer.stop()
		timer = null
	if tween:
		tween.kill()
		tween = null

func _on_section_complete() -> void:
	# print("Section ", section_index, " complete.")
	if !running:
		return
	_move_to_next_section()
	_start_section_movement()

#endregion
