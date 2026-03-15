@tool

extends Control

@onready var up_button: TouchScreenButton = $UpButton
@onready var down_button: TouchScreenButton = $DownButton
@onready var shoot_button: TouchScreenButton = $ShootButton

func _physics_process(_delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size

	var direction_button_size = viewport_size * Vector2(0.5, 0.5)
	
	up_button.shape.size = direction_button_size
	up_button.position = direction_button_size * Vector2(0.5, 0.5)

	down_button.shape.size = direction_button_size
	down_button.position = direction_button_size * Vector2(0.5, 1.5)

	shoot_button.shape.size = viewport_size * Vector2(0.5, 1.0)
	shoot_button.position = viewport_size * Vector2(0.75, 0.5)
