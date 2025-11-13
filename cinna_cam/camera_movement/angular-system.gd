class_name AngularSystem extends Resource

@export var f := 4.0 # natural frequency (cycles/sec)
@export var z := 1.8 # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
@export var r := 0.8 # response factor (>1 overshoots, =1 matches, <1 anticipates)

var _k1: float
var _k2: float
var _k3: float
var _t_critical: float

var _velocity: float = 0.0

var _target_angle: float = 0.0
var _prev_target_angle: float = 0.0

var _angle: float = 0.0

var float_small: float = 1e-6
var _top_angle_limit: float = 0.5 * PI - float_small
var _bottom_angle_limit: float = -0.5 * PI + float_small


func initialize(start_angle: float) -> void:
	_angle = start_angle
	_prev_target_angle = start_angle


func get_next_angle(target_angle: float, delta: float) -> float:
	_k1 = z / (PI * f)
	_k2 = 1.0 / pow(2.0 * PI * f, 2)
	_k3 = r * z / (2.0 * PI * f)
	_t_critical = 0.8 * f * (sqrt(4.0 * _k2 + _k1 * _k1) - _k1)
	_target_angle = target_angle

	# instantly rotate full revolution backwards if crossing the +/- PI boundary
	if _target_angle > 2.8 and _angle < -2.8:
		_angle += TAU
		_prev_target_angle = _target_angle
		return _angle
	if _target_angle < -2.8 and _angle > 2.8:
		_angle -= TAU
		_prev_target_angle = _target_angle
		return _angle

	var iterations := int(delta / _t_critical) + 1
	var step := delta / iterations

	for i in range(iterations):
		var accel = (_target_angle + _k3 * 0.0 - _angle - _k1 * _velocity) / _k2
		_velocity += accel * step
		_angle += _velocity * step

	return _angle


func get_next_constrained_angle(target_angle: float, delta: float) -> float:
	_k1 = z / (PI * f)
	_k2 = 1.0 / pow(2.0 * PI * f, 2)
	_k3 = r * z / (2.0 * PI * f)
	_t_critical = 0.8 * f * (sqrt(4.0 * _k2 + _k1 * _k1) - _k1)
	_target_angle = clamp(target_angle, _bottom_angle_limit, _top_angle_limit)

	# var target_velocity_est = (_target_angle - _prev_target_angle) / delta
	_prev_target_angle = _target_angle

	var iterations := int(delta / _t_critical) + 1
	var step := delta / iterations

	for i in range(iterations):
		# replaced target_velocity_est with 0.0 bc it seems smoother
		var accel = (_target_angle + _k3 * 0.0 - _angle - _k1 * _velocity) / _k2
		_velocity += accel * step
		_angle += _velocity * step

	return clamp(_angle, _bottom_angle_limit, _top_angle_limit)
