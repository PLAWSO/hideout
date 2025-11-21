@tool
class_name PlanarSystem extends Resource

@export var f := 2.0 # natural frequency (cycles/sec)
@export var z := 1.8 # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
@export var r := 0.8 # response factor (>1 overshoots, =1 matches, <1 anticipates)

var _position := Vector3.ZERO
var _velocity := Vector3.ZERO
var _prev_target_pos := Vector3.ZERO

func initialize(start_position: Vector3) -> void:
	_position = start_position
	_velocity = Vector3.ZERO
	_prev_target_pos = start_position


func get_next_position(target_pos: Vector3, delta: float) -> Vector3:
	var frequency = TAU * f

	var target_velocity = (target_pos - _prev_target_pos) / delta
	_prev_target_pos = target_pos

	var damping_factor = exp(-z * frequency * delta)

	if z < 1.0:
		# underdamped
		var oscillation_coef = sqrt(1.0 - z * z)
		var damped_frequency = frequency * oscillation_coef
		var lambda1 = cos(damped_frequency * delta)
		var lambda2 = sin(damped_frequency * delta)

		var position_factor = damping_factor * (lambda1 + (z / oscillation_coef) * lambda2)
		var velocity_factor = damping_factor * (lambda2 / (damped_frequency))

		var distance_from_target = _position - target_pos
		var velocity_est = _velocity - r * target_velocity

		var new_x = position_factor * distance_from_target + velocity_factor * velocity_est
		var new_v = -damped_frequency * damping_factor * lambda2 * distance_from_target + damping_factor * (lambda1 - (z / oscillation_coef) * lambda2) * velocity_est

		_position = new_x + target_pos
		_velocity = new_v + r * target_velocity
		return _position

	elif z == 1.0:
		# critically damped
		var position_factor = damping_factor * (1.0 + frequency * delta)
		var velocity_factor = damping_factor * delta

		var distance_from_target = _position - target_pos
		var velocity_est = _velocity - r * target_velocity

		var new_x = position_factor * distance_from_target + velocity_factor * velocity_est
		var new_v = damping_factor * (velocity_est - frequency * distance_from_target - frequency * velocity_est * delta)

		_position = new_x + target_pos
		_velocity = new_v + r * target_velocity
		return _position

	else:
		# overdamped
		var separation_coefficient = sqrt(z * z - 1.0)
		var lambda1 = -frequency * (z - separation_coefficient)
		var lambda2 = -frequency * (z + separation_coefficient)

		var e1 = exp(lambda1 * delta)
		var e2 = exp(lambda2 * delta)

		var distance_from_target = _position - target_pos
		var velocity_est = _velocity - r * target_velocity

		var new_x = (e1 * (lambda2 * distance_from_target - velocity_est) - e2 * (lambda1 * distance_from_target - velocity_est)) / (lambda2 - lambda1)
		var new_v = (e1 * lambda1 * (lambda2 * distance_from_target - velocity_est) - e2 * lambda2 * (lambda1 * distance_from_target - velocity_est)) / (lambda2 - lambda1)

		_position = new_x + target_pos
		_velocity = new_v + r * target_velocity
		return _position
