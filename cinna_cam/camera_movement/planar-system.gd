@tool
class_name PlanarSystem extends Resource

@export var f := 2.0 # natural frequency (cycles/sec)
@export var z := 1.8 # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
@export var r := 0.8 # response factor (>1 overshoots, =1 matches, <1 anticipates)

var _k1: float
var _k2: float
var _k3: float
var _t_critical: float

var _position := Vector3.ZERO
var _velocity := Vector3.ZERO

var _prev_target_position := Vector3.ZERO
var _target_position := Vector3.ZERO

func initialize(start_position: Vector3) -> void:
	_position = start_position
	_target_position = start_position
	_prev_target_position = start_position

func get_next_position(target_position: Vector3, delta: float) -> Vector3:
	_k1 = z / (PI * f)
	_k2 = 1.0 / pow(2.0 * PI * f, 2)
	_k3 = r * z / (2.0 * PI * f)
	_t_critical = 0.8 * f * (sqrt(4.0 * _k2 + _k1 * _k1) - _k1)

	_target_position = target_position
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
