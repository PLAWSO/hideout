extends Node3D

@onready var screen_2: MeshInstance3D = $Screen2

var console
var tween

func _ready() -> void:
	Events.camera_moved.connect(_on_camera_moved)
	Events.arrived_at_meta_path.connect(_on_arrived_at_meta_path)
	Events.left_meta_path.connect(_on_left_meta_path)
	console = JavaScriptBridge.get_interface("window")

func _on_camera_moved() -> void:
	var screen_verts := screen_2.mesh.get_faces()

	var current_camera := get_viewport().get_camera_3d()

	if current_camera.is_position_behind(screen_2.global_transform.origin):
		return
	
	var p1: Vector2 = Vector2(INF, INF)
	var p2: Vector2 = Vector2(-INF, -INF)

	for i in range(screen_verts.size()):
		var unprojected := current_camera.unproject_position(screen_verts[i] + screen_2.global_transform.origin)
		p1.x = min(p1.x, unprojected.x)
		p1.y = min(p1.y, unprojected.y)
		p2.x = max(p2.x, unprojected.x)
		p2.y = max(p2.y, unprojected.y)

	var size := p2 - p1
	
	if console:
		var godot_viewport := get_viewport().get_visible_rect().size
		var scale_x = JSBridge.canvas_width / godot_viewport.x
		var scale_y = JSBridge.canvas_height / godot_viewport.y
		
		console.setTerminalBounds(p1.x * scale_x, p1.y * scale_y, size.x * scale_x, size.y * scale_y)

func _on_arrived_at_meta_path(meta_path_index: int) -> void:
	if meta_path_index == 4:
		tween = create_tween()
		tween.tween_property(screen_2.get_active_material(0), "shader_parameter/signal_strength", 1.0, 0.5).from(0.0)
		if console:
			console.setTerminalVisibility(true)

func _on_left_meta_path(meta_path_index: int) -> void:
	if meta_path_index != 4:
		if tween:
			tween.stop()

		screen_2.get_active_material(0).set_shader_parameter("signal_strength", 0.0)
		if console:
			console.setTerminalVisibility(false)
