@tool
class_name SecondOrderCameraMovement extends Node

var targets: Array[Node3D] = []

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

var _target_index: int = 0
 
func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is Node3D:
			targets.append(child)

	if not _validate_node_setup():
		return

	# initialize dynamic constants
	_k1 = z / (PI * f)
	_k2 = 1.0 / pow(2.0 * PI * f, 2)
	_k3 = r * z / (2.0 * PI * f)
	_t_critical = 0.8 * f * (sqrt(4.0 * _k2 + _k1 * _k1) - _k1)

	# initialize calculation state
	_target_position = _get_current_target_position()
	_prev_target_position = _target_position

func get_next_position(delta: float) -> Vector3:
	_target_position = _get_current_target_position()
	var target_velocity_est = (_target_position - _prev_target_position) / delta
	_prev_target_position = _target_position
	
	# break delta into smaller integration steps for stability
	var iterations := int(delta / _t_critical) + 1
	var step := delta / iterations
	
	for i in range(iterations):
		# can also use Vector3.ZERO for target_velocity_est for no velocity compensation
		var accel = (_target_position + _k3 * target_velocity_est - _position - _k1 * _velocity) / _k2
		_velocity += accel * step
		_position += _velocity * step
	
	return _position

func set_start_position(position: Vector3) -> void:
	_position = position

func set_movement_target(index: int) -> void:
	if index >= 0 and index < targets.size():
		print("switching to camera target ", index)
		_target_index = index
		_target_position = _get_current_target_position()
		_prev_target_position = _target_position

func _get_current_target_position() -> Vector3:
	if "target" in targets[_target_index]:
		return targets[_target_index].target.global_position
	else:
		return targets[_target_index].global_position

#region Validate
func _validate_node_setup() -> bool:
	var valid := true
	if targets.size() == 0 or targets[0] == null:
		push_error("\"Movement Targets\" are not assigned.")
		valid = false
	return valid
#endregion
