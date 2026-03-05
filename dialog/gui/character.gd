extends MarginContainer

@onready var wave_animation: Sprite2D = $WaveAnimation

func _ready() -> void:
	Events.switch_intro_animation_to_nod.connect(_on_switch_intro_animation_to_nod)

func _on_switch_intro_animation_to_nod() -> void:
	wave_animation.visible = false
