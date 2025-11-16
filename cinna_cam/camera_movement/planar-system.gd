@tool
class_name PlanarSystem extends Resource

@export var f := 2.0 # natural frequency (cycles/sec)
@export var z := 1.8 # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
@export var r := 0.8 # response factor (>1 overshoots, =1 matches, <1 anticipates)

var _position := Vector3.ZERO
var _velocity := Vector3.ZERO
var _prev_target := Vector3.ZERO

func initialize(start_position: Vector3) -> void:
	_position = start_position
	_velocity = Vector3.ZERO
	_prev_target = start_position


func get_next_position(target: Vector3, delta: float) -> Vector3:
	var omega = TAU * f   # natural angular frequency

	# target velocity estimate (can be zero if you don't want anticipation)
	var y = target
	var y_dot = (y - _prev_target) / delta
	_prev_target = y

	# Damp depending on regime
	var e = exp(-z * omega * delta)

	if z < 1.0:
		# underdamped
		var c = sqrt(1.0 - z * z)
		var omega_d = omega * c

		var cos_calc = cos(omega_d * delta)
		var sin_calc = sin(omega_d * delta)

		var A = e * (cos_calc + (z / c) * sin_calc)
		var B = e * (sin_calc / (omega_d))

		var x = _position - y
		var v = _velocity - r * y_dot

		var new_x = A * x + B * v
		var new_v = -omega_d * e * sin_calc * x + e * (cos_calc - (z / c) * sin_calc) * v

		_position = new_x + y
		_velocity = new_v + r * y_dot
		return _position

	elif z == 1.0:
		# critically damped
		var A = e * (1.0 + omega * delta)
		var B = e * delta

		var x = _position - y
		var v = _velocity - r * y_dot

		var new_x = A * x + B * v
		var new_v = e * (v - omega * x - omega * v * delta)

		_position = new_x + y
		_velocity = new_v + r * y_dot
		return _position

	else:
		# overdamped
		var s = sqrt(z * z - 1.0)
		var lambda1 = -omega * (z - s)
		var lambda2 = -omega * (z + s)

		var e1 = exp(lambda1 * delta)
		var e2 = exp(lambda2 * delta)

		var x = _position - y
		var v = _velocity - r * y_dot

		var new_x = (e1 * (lambda2 * x - v) - e2 * (lambda1 * x - v)) / (lambda2 - lambda1)
		var new_v = (e1 * lambda1 * (lambda2 * x - v) - e2 * lambda2 * (lambda1 * x - v)) / (lambda2 - lambda1)

		_position = new_x + y
		_velocity = new_v + r * y_dot
		return _position
