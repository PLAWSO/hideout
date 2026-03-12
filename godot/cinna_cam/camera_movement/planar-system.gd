@tool
class_name PlanarSystem extends Resource

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

var _position := Vector3.ZERO
var _velocity := Vector3.ZERO
var _prev_target := Vector3.ZERO

func _compute_constants() -> void:
	_w = 2.0 * PI * f
	_d = _w * sqrt(abs(z * z - 1.0))

	_k1 = z / (PI * f)
	_k2 = 1.0 / (_w * _w)
	_k3 = r * z / _w

#endregion

#region Lifecycle

func initialize(start_position: Vector3) -> void:
	_position = start_position
	_velocity = Vector3.ZERO
	_prev_target = start_position

	_compute_constants()

#endregion

#region Methods

func get_next_position(target_pos: Vector3, delta: float) -> Vector3:
	var xd = (target_pos - _prev_target) / delta
	_prev_target = target_pos

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
	
	_position = _position + _velocity * delta
	_velocity = _velocity + delta * (target_pos + _k3 * xd - _position - _k1 * _velocity) / k2_stable
	return _position

#endregion