extends Node3D

@onready var camera_controller: Node = $CameraController

#region Input Handling
func _unhandled_input(event: InputEvent) -> void:
	print("camera_target", )
	if event.is_action_pressed("camera_0"):
		camera_controller.set_movement_target(0)
	if event.is_action_pressed("camera_1"):
		camera_controller.set_movement_target(1)
	# if event.is_action_pressed("camera_2"):
	# 	camera_controller.set_look_target(2)
	# if event.is_action_pressed("camera_3"):
	# 	camera_controller.set_look_target(3)
	# if event.is_action_pressed("camera_4"):
	# 	camera_controller.set_look_target(4)
	# if event.is_action_pressed("camera_5"):
	# 	camera_controller.set_look_target(5)
	# if event.is_action_pressed("camera_6"):
	# 	camera_controller.set_look_target(6)
	# if event.is_action_pressed("camera_7"):
	# 	camera_controller.set_look_target(7)
	# if event.is_action_pressed("camera_8"):
	# 	camera_controller.set_look_target(8)


#endregion
