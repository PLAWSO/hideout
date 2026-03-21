class_name Obstacle extends Node2D

var speed: float = 400.0
var speed_tween: Tween = null

@onready var hit_box: Area2D = $HitBox

func move(delta: float) -> void:
	position.x -= speed * delta  