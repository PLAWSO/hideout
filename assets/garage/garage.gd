@tool
extends Node3D

@export_group("Visibility")
@export var hideCeiling: bool = false
@export var hideProps: bool = false
@export var hideWalls: bool = false

func _set_floor_visibility() -> void:
	$Ceiling.visible = !hideCeiling
	$Props.visible = !hideProps
	$Walls.visible = !hideWalls

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_set_floor_visibility()
	pass
