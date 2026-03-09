@tool

extends Node2D

@export var ship: StaticBody2D
@export var projectile: StaticBody2D
@export var obstacle: StaticBody2D
@export var difficulty: int = 1

@export var rest_pos: Vector2:
	set(value):
		rest_pos = value
		if ship:
			ship.position = rest_pos
	get:
		return rest_pos

@export var move_distance: float = 50.0


var up_pressed: bool = false
var down_pressed: bool = false

#region Input Handling

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		up_pressed = true
	elif event.is_action_pressed("down"):
		down_pressed = true
	elif event.is_action_released("up"):
		up_pressed = false
	elif event.is_action_released("down"):
		down_pressed = false
	elif event.is_action_pressed("shoot"):
		_shoot()

		
#endregion

func _shoot() -> void:
	if not projectile.visible:
		projectile.visible = true
		projectile.position = ship.position
	

func _ready() -> void:
	# projectile.visible = false
	ship.position = rest_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if up_pressed and not down_pressed:
		ship.position.y = rest_pos.y - move_distance
	elif down_pressed and not up_pressed:
		ship.position.y = rest_pos.y + move_distance
	else:
		ship.position = rest_pos

	if projectile.visible:
		projectile.position.x += 800 * delta
		if projectile.position.x > 800:
			projectile.visible = false
	
	if randi() % 50 * difficulty:
		obstacle.position.x -= 400 * delta
		if obstacle.position.x < -100:
			obstacle.position.x = 900
			var track = randi() % 3
			if track == 0:
				obstacle.position.y = rest_pos.y - move_distance
			elif track == 1:
				obstacle.position.y = rest_pos.y
			else:
				obstacle.position.y = rest_pos.y + move_distance
	



