extends Node3D

@onready var screen: MeshInstance3D = $Screen

var tween

func _ready() -> void:
	Events.arrived_at_meta_path.connect(_on_arrived_at_meta_path)
	Events.left_meta_path.connect(_on_left_meta_path)


func get_bounds() -> Rect2:
	var current_camera := get_viewport().get_camera_3d()

	if current_camera.is_position_behind(screen.global_transform.origin):
		return Rect2(0, 0, 0, 0)
	
	var p1: Vector2 = Vector2(INF, INF)
	var p2: Vector2 = Vector2(-INF, -INF)
	var screen_verts := screen.mesh.get_faces()
	
	for i in range(screen_verts.size()):
		var unprojected := current_camera.unproject_position(screen_verts[i] + screen.global_transform.origin)
		p1.x = min(p1.x, unprojected.x)
		p1.y = min(p1.y, unprojected.y)
		p2.x = max(p2.x, unprojected.x)
		p2.y = max(p2.y, unprojected.y)

	return Rect2(p1, p2 - p1)


func _on_arrived_at_meta_path(meta_path_index: int) -> void:
	if meta_path_index == 4:
		tween = create_tween()
		tween.tween_property(screen.get_active_material(0), "shader_parameter/signal_strength", 1.0, 0.5).from(0.0)
		JSBridge.set_terminal_gui_visible(true)


func _on_left_meta_path(meta_path_index: int) -> void:
	if meta_path_index != 4:
		if tween:
			tween.stop()

		screen.get_active_material(0).set_shader_parameter("signal_strength", 0.0)
		JSBridge.set_terminal_gui_visible(false)
