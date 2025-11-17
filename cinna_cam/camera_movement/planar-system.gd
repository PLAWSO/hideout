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
	var angular_frequency = TAU * f   # natural angular frequency

	# target velocity estimate (can be zero if you don't want anticipation)
	var y = target
	var target_velocity = (y - _prev_target) / delta
	_prev_target = y

	# Damp depending on regime
	var damping_factor = exp(-z * angular_frequency * delta)

	if z < 1.0:
		# underdamped
		var c = sqrt(1.0 - z * z)
		var omega_d = angular_frequency * c

		var cos_calc = cos(omega_d * delta)
		var sin_calc = sin(omega_d * delta)

		var A = damping_factor * (cos_calc + (z / c) * sin_calc)
		var B = damping_factor * (sin_calc / (omega_d))

		var x = _position - y
		var v = _velocity - r * target_velocity

		var new_x = A * x + B * v
		var new_v = -omega_d * damping_factor * sin_calc * x + damping_factor * (cos_calc - (z / c) * sin_calc) * v

		_position = new_x + y
		_velocity = new_v + r * target_velocity
		return _position

	elif z == 1.0:
		# critically damped
		var position_factor = damping_factor * (1.0 + angular_frequency * delta)
		var velocity_factor = damping_factor * delta

		var distance_from_target = _position - y
		var current_velocity = _velocity - r * target_velocity

		var new_x = position_factor * distance_from_target + velocity_factor * current_velocity
		var new_v = damping_factor * (current_velocity - angular_frequency * distance_from_target - angular_frequency * current_velocity * delta)

		_position = new_x + y
		_velocity = new_v + r * target_velocity
		return _position

	else:
		# overdamped
		var s = sqrt(z * z - 1.0)
		var lambda1 = -angular_frequency * (z - s)
		var lambda2 = -angular_frequency * (z + s)

		var e1 = exp(lambda1 * delta)
		var e2 = exp(lambda2 * delta)

		var x = _position - y
		var v = _velocity - r * target_velocity

		var new_x = (e1 * (lambda2 * x - v) - e2 * (lambda1 * x - v)) / (lambda2 - lambda1)
		var new_v = (e1 * lambda1 * (lambda2 * x - v) - e2 * lambda2 * (lambda1 * x - v)) / (lambda2 - lambda1)

		_position = new_x + y
		_velocity = new_v + r * target_velocity
		return _position
