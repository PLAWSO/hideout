class_name Missile extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $NearMissBox/CollisionShape2D

var speed: float = 1000.0
var moving_forward: bool = true

# func _ready() -> void:


func move(delta: float) -> void:
	if moving_forward:
		position.x += speed * delta
	else:
		position.x -= speed * delta

func _on_hit_box_area_entered(area: Area2D) -> void:
	if (area.name == "HitBox"):
		moving_forward = false
		sprite_2d.flip_h = true
		collision_shape_2d.position -= Vector2(collision_shape_2d.shape.size.x, 0)
	return


	pass # Replace with function body.
