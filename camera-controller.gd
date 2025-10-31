class_name CameraController extends SecondOrderTargeting

@export_group("Nodes")
@export var movement_targets: Array[Node3D] = []
@export var object_to_move: Node3D
@export var look_targets: Array[PathFollow3D] = []

@export_group("Dynamic Constants")
@export var f := 1.0 # natural frequency (cycles/sec)
@export var z := 1.0 # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
@export var r := 2.0 # response factor (>1 overshoots, =1 matches, <1 anticipates)