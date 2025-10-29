extends Node3D

@export_group("Visibility")
@export var Structure := true
@export var Props := true
@export var Floor := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Structure.visible = Structure
	$Props.visible = Props
	$Floor.visible = Floor
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
