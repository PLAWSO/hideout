@tool
class_name AngularSystem extends Resource

#region Properties

@export var f := 2.0: # natural frequency (cycles/sec)
	set(value):
		f = value
		_compute_constants()
@export var z := 1.8: # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
	set(value):
		z = value
		_compute_constants()
@export var r := 0.8: # response factor (>1 overshoots, =1 matches, <1 anticipates)
	set(value):
		r = value
		_compute_constants()

var _w: float
var _d: float
var _k1: float
var _k2: float
var _k3: float

var _velocity: float = 0.0
var _angle: float = 0.0
var _prev_target: float = 0.0

var float_small := 1e-6
var _top_angle_limit := 0.5 * PI - float_small
var _bottom_angle_limit := -0.5 * PI + float_small

func _compute_constants() -> void:
	_w = 2.0 * PI * f
	_d = _w * sqrt(abs(z * z - 1.0))

	_k1 = z / (PI * f)
	_k2 = 1.0 / (_w * _w)
	_k3 = r * z / _w

#endregion

#region Lifecycle

func initialize(start_angle: float) -> void:
	_angle = start_angle
	_velocity = 0.0
	_prev_target = start_angle

	_compute_constants()

#endregion

#region Methods

func _compute_closed_form(target_angle: float, delta: float) -> float:
	var xd = (target_angle - _prev_target) / delta
	_prev_target = target_angle

	var k1_stable: float
	var k2_stable: float
	if (_w * delta) < z:
		k1_stable = _k1
		k2_stable = max(_k2, delta * delta / 2.0 + delta * _k1 / 2.0, delta * _k1)
	else:
		var t1 = exp(-z * _w * delta)
		var alpha = 2.0 * t1 * cos(_d * delta) if z < 1.0 else cosh(_d * delta)
		var beta = t1 * t1
		var t2 = delta / (1.0 + beta - alpha)
		k1_stable = (1.0 - beta) * t2
		k2_stable = delta * t2
	
	_angle = _angle + _velocity * delta
	_velocity = _velocity + delta * (target_angle + _k3 * xd - _angle - _k1 * _velocity) / k2_stable
	return _angle

func get_next_angle(target_angle: float, delta: float) -> float:
	if _angle > .0:
		if target_angle < _angle - PI:
			_angle -= TAU
	elif _angle < .0:
		if target_angle > _angle + PI:
			_angle += TAU

	return _compute_closed_form(target_angle, delta)


func get_next_constrained_angle(target_angle: float, delta: float) -> float:
	target_angle = clamp(target_angle, _bottom_angle_limit, _top_angle_limit)

	return _compute_closed_form(target_angle, delta)

#endregion