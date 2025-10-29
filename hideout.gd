extends Node3D

@onready var pointer: MeshInstance3D = $Pointer
@onready var camera: Camera3D = $Camera3D
@onready var look_path: Path3D = $LookAt
@onready var follow_path: Path3D = $Path3D

@export_group("Dynamic Constants")
@export var f := 1.0 # cycles per second
@export var z := 1.0 # damping coefficient; > 1 is overdamped, = 1 is critically damped, < 1 is underdamped
@export var r := 2.0 # response speed; > 1 will overshoot, 1 reacts instantly, < 1 will anticipate


var k1: float
var k2: float
var k3: float

var velocity_est: Vector3 = Vector3.ZERO
var previous_camera_global_position = Vector3.ZERO
var new_position = Vector3.ZERO
var velocity = Vector3.ZERO

var object_to_move: Node3D

func _ready() -> void:

	Engine.time_scale = 0
	object_to_move = pointer

	k1 = z / (PI * f) 
	k2 = 1 / ((2 * PI * f) * (2 * PI * f))
	k3 = r * z / (2 * PI * f)

func _process(delta: float) -> void:
	if (velocity_est == Vector3.ZERO):
		velocity_est = (object_to_move.global_position - previous_camera_global_position) / delta
		previous_camera_global_position = object_to_move.global_position

	new_position = new_position + delta * velocity
	velocity = velocity + delta * object_to_move.global_position + (k3 * velocity_est) - new_position - (k1 * velocity) / k2
	print("new_position: ", new_position)
	object_to_move.global_position = new_position







	# print("velocity_est: ", velocity_est)
	# create_tween().tween_property(camera, "progress_ratio", path_follow.progress_ratio, 0.5)
	# camera.global_position = path_follow.global_position
	# camera.look_at(look_at.global_position, Vector3.UP)

# func _unhandled_input(event: InputEvent) -> void:
	# if event.is_action_pressed("left"):
	# 	create_tween().tween_property(path_follow, "progress_ratio", 0, 0.5)
	# 	create_tween().tween_property(look_at, "progress_ratio", 0, 0.5)

	# if event.is_action_pressed("right"):
	# 	create_tween().tween_property(path_follow, "progress_ratio", 1, 0.5)
	# 	create_tween().tween_property(look_at, "progress_ratio", 1, 0.5)
 
