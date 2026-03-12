@tool
class_name TestCam extends Camera3D

@onready var preview_mesh: Node3D = $PreviewMesh

@export var show_preview_mesh: bool = true:
	set(value):
		show_preview_mesh = value
		if preview_mesh:
			preview_mesh.visible = show_preview_mesh

func _ready() -> void:
	if not Engine.is_editor_hint():
		preview_mesh.visible = show_preview_mesh
