@tool
class_name SecondOrderTargeting extends Node

@export_group("Nodes")
@export var object_to_move: Node3D = null
@export var movement_targets: Array[Node3D] = []
@export var look_targets: Array[PathFollow3D] = []

@export_group("Dynamic Constants")
@export var f := 1.0 # natural frequency (cycles/sec)
@export var z := 1.0 # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
@export var r := 2.0 # response factor (>1 overshoots, =1 matches, <1 anticipates)

var _k1: float
var _k2: float
var _k3: float
var _t_critical: float

var _position := Vector3.ZERO
var _velocity := Vector3.ZERO

var _prev_target_position := Vector3.ZERO
var _target_position := Vector3.ZERO

var _movement_target_index: int = 0
var _look_target_index: int = 0

func _ready() -> void:
	if not validate_node_setup():
		return

	# initialize dynamic constants
	_k1 = z / (PI * f)
	_k2 = 1.0 / pow(2.0 * PI * f, 2)
	_k3 = r * z / (2.0 * PI * f)
	_t_critical = 0.8 * f * (sqrt(4.0 * _k2 + _k1 * _k1) - _k1)

	# initialize calculation state
	_position = object_to_move.global_position
	_prev_target_position = movement_targets[_movement_target_index].global_position
	_target_position = movement_targets[_movement_target_index].target.global_position

func _process(delta: float) -> void:
	if _movement_target_index == 0:
		_target_position = movement_targets[_movement_target_index].target.global_position
	else:
		_target_position = movement_targets[_movement_target_index].global_position
	var target_velocity_est = (_target_position - _prev_target_position) / delta
	_prev_target_position = _target_position
	
	# Break delta into smaller integration steps for stability
	var iterations := int(delta / _t_critical) + 1
	var step := delta / iterations
	
	for i in range(iterations):
		# can also use Vector3.ZERO for target_velocity_est for no velocity compensation
		var accel = (_target_position + _k3 * target_velocity_est - _position - _k1 * _velocity) / _k2
		_velocity += accel * step
		_position += _velocity * step
	
	object_to_move.global_position = _position

	# Align rotation with movement direction (optional but useful)
	# if velocity.length() > 0.001:
	# 	object_to_move.look_at(new_position + velocity.normalized(), Vector3.UP)

func set_movement_target(index: int) -> void:
	if index >= 0 and index < movement_targets.size():
		if index == 0:
			_target_position = movement_targets[index].target.global_position
		else:
			_target_position = movement_targets[index].global_position
		_prev_target_position = _target_position
		_movement_target_index = index

func set_look_target(index: int) -> void:
	if index >= 0 and index < look_targets.size():
		_look_target_index = index

#region Validate
func validate_node_setup() -> bool:
	var valid := true
	if object_to_move == null:
		push_error("\"Object to Move\" is not assigned.")
		valid = false
	if movement_targets.size() == 0 or movement_targets[0] == null:
		push_error("\"Movement Targets\" are not assigned.")
		valid = false
	return valid
#endregion
