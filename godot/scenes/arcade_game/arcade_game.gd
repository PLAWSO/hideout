extends Node2D

####################################
## SHARED                         ##
####################################

# PHYSICS
const physics_frame_rate: float = 30.0

# PLAYER
@export var ship: Area2D


# GUI ELEMENTS
@onready var points_counter: PointsCounter = $PointsCounter
@onready var top_track_indicator: Sprite2D = $TopTrackIndicator
@onready var middle_track_indicator: Sprite2D = $MiddleTrackIndicator
@onready var bottom_track_indicator: Sprite2D = $BottomTrackIndicator


# LAYOUT
@export var off_screen_right: float = 900.0
@export var off_screen_left: float = -100.0
@export var move_distance: float = 50.0

@export var rest_pos: Vector2:
	set(value):
		rest_pos = value
		if ship:
			ship.position = rest_pos
	get:
		return rest_pos

@export var difficulty: int = 1


# STATE
var alive: bool = false

####################################
## LIFETIME                       ##
####################################

func _ready() -> void:
	create_obstacles()
	ship.position = rest_pos
	top_track_indicator.position = rest_pos + Vector2(75, -move_distance)
	middle_track_indicator.position = rest_pos + Vector2(75, 0)
	bottom_track_indicator.position = rest_pos + Vector2(75, move_distance)


func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	for obstacle in enabled_obstacles:
		obstacle.move(_delta)

	if not alive:
		return

	# OBSTACLES
	check_recycle_obstacles()
	check_spawn_obstacles()

	# SHIP
	move_ship()

func stop_game() -> void:
	for obstacle in enabled_obstacles:
		obstacle.speed = 0.0
	for obstacle in disabled_obstacles:
		obstacle.speed = 0.0
	alive = false


func reset_game() -> void:
	set_in_near_miss(false)
	points_counter.reset()

	reset_obstacles()

	ship.position.y = rest_pos.y

	alive = true
	reset_input()


####################################
## INPUT                          ##
####################################

var up_pressed: bool = false
var down_pressed: bool = false

func input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		up_pressed = true
	elif event.is_action_pressed("down"):
		down_pressed = true
	elif event.is_action_released("up"):
		up_pressed = false
	elif event.is_action_released("down"):
		down_pressed = false
	elif event.is_action_pressed("shoot") and alive:
		shoot()
	elif event.is_action_released("shoot") and not alive:
		reset_game()
	

func move_ship() -> void:
	if not alive:
		return
	if up_pressed and not down_pressed:
		ship.position.y = rest_pos.y - move_distance
	elif down_pressed and not up_pressed:
		ship.position.y = rest_pos.y + move_distance
	else:
		ship.position.y = rest_pos.y

func reset_input() -> void:
	up_pressed = false
	down_pressed = false

####################################
## POINTS                         ##
####################################

@export var near_miss_point_factor: float = 1000.0
var in_early_near_miss: bool = false


# PUBLIC METHODS
###########################


func set_in_near_miss(value: bool) -> void:
	in_early_near_miss = value


func award_early_near_miss_points(distance: float) -> void:
	if not (in_early_near_miss and alive):
		return
	_award_near_miss_points(distance)


func award_late_near_miss_points(distance: float) -> void:
	if not alive:
		return
	_award_near_miss_points(distance)


# PRIVATE METHODS
###########################


func _award_near_miss_points(distance: float) -> void:
	points_counter.add_points(round(near_miss_point_factor / distance))


####################################
## OBSTACLES                      ##
####################################


@export var ObstacleScene: PackedScene
@export var number_of_obstacles: int = 5
@export var obstacle_speed: float = 400.0

var _spawn_every_n_frames: int = 30
@export_range(0.5, 10.0, 0.1) var obstacle_spawn_interval:
	get:
		return obstacle_spawn_interval
	set(value):
		obstacle_spawn_interval = value
		_spawn_every_n_frames = int(physics_frame_rate * obstacle_spawn_interval)

var enabled_obstacles: Array[Obstacle] = []
var disabled_obstacles: Array[Obstacle] = []
var frames_since_last_spawn: int = 0


# PUBLIC METHODS
###########################


# used at game start to create obstacles
func create_obstacles() -> void:
	for i in range(number_of_obstacles):
		var obstacle := ObstacleScene.instantiate()
		self.add_child(obstacle)
		_disable_obstacle(obstacle)
		disabled_obstacles.append(obstacle)


# used during restart to reset obstacles 
func reset_obstacles() -> void:
	for obstacle in enabled_obstacles:
		_disable_obstacle(obstacle)
		disabled_obstacles.append(obstacle)
	enabled_obstacles.clear()

	for obstacle in disabled_obstacles:
		obstacle.speed = obstacle_speed

# used on physics frame to check for and recycle off-screen obstacles
func check_recycle_obstacles() -> void:
	for obstacle in enabled_obstacles:
		if obstacle.position.x < off_screen_left:
			_recycle_obstacle(obstacle)


# used on physics frame to check for and spawn new obstacles
func check_spawn_obstacles() -> void:
	frames_since_last_spawn += 1
	if frames_since_last_spawn >= _spawn_every_n_frames:
		frames_since_last_spawn = 0
		_spawn_obstacle()


# PRIVATE METHODS
###########################


# used to recycle an obstacle that has gone off-screen
func _recycle_obstacle(obstacle: Obstacle) -> void:
	enabled_obstacles.erase(obstacle)
	_disable_obstacle(obstacle)
	disabled_obstacles.append(obstacle)


# used to disable an obstacle
func _disable_obstacle(obstacle: Obstacle) -> void:
	obstacle.speed = obstacle_speed
	obstacle.visible = false
	obstacle.hit_box.monitorable = false
	obstacle.hit_box.set_process(false)
	obstacle.position = Vector2(off_screen_right, rest_pos.y)


# used to spawn an obstacle
func _spawn_obstacle() -> void:
	var obstacle = _enable_obstacle()
	if not obstacle:
		return
	
	var track = randi() % 3
	if track == 0:
		obstacle.position.y = rest_pos.y - move_distance
	elif track == 1:
		obstacle.position.y = rest_pos.y
	else:
		obstacle.position.y = rest_pos.y + move_distance


# used to enable an obstacle from the disabled pool
func _enable_obstacle() -> Obstacle:
	var obstacle: Obstacle = disabled_obstacles.pop_back()
	if not obstacle:
		return null

	obstacle.visible = true
	obstacle.hit_box.monitorable = true
	obstacle.hit_box.set_process(true)
	obstacle.position.x = off_screen_right
	enabled_obstacles.append(obstacle)
	return obstacle


####################################
## PROJECTILES                    ##
####################################

@export var projectile: Area2D
var projectile_speed: float = 800.0

func shoot() -> void:
	# if not projectile.visible:
	# 	projectile.visible = true
	# 	projectile.position = ship.position
	pass


####################################
## COLLISIONS                     ##
####################################

func _on_ship_area_entered(area: Area2D) -> void:
	if (area.name == "HitBox"):
		stop_game()
		JSBridge.save_score(points_counter.total_points)
		return

	elif (area.name == "NearMissBox"):
		var behind_obstacle := area.global_position.x < ship.global_position.x
		if behind_obstacle:
			var distance = abs(area.global_position.x - ship.global_position.x)
			award_late_near_miss_points(distance)
			return
		
		set_in_near_miss(true)


func _on_ship_area_exited(area: Area2D) -> void:
	if area.name != "NearMissBox":
		return

	var distance = abs(area.global_position.x - ship.global_position.x)
	award_early_near_miss_points(distance)
	
	set_in_near_miss(false)


func _on_projectile_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
