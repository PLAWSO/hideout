class_name Projectile extends Area2D

var speed: float = 400.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	position.x += speed * delta