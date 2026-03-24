extends Node2D

####################################
## SHARED                         ##
####################################

# PHYSICS
const physics_frame_rate: float = 30.0

# PLAYER
@export var ship: Area2D


# GUI ELEMENTS
@onready var points_counter: PointsCounter = $GameAssets/PointsCounter
@onready var top_track_indicator: Sprite2D = $GameAssets/TopTrackIndicator
@onready var middle_track_indicator: Sprite2D = $GameAssets/MiddleTrackIndicator
@onready var bottom_track_indicator: Sprite2D = $GameAssets/BottomTrackIndicator


# LAYOUT
@export var off_screen_right: float = 900.0
@export var off_screen_left: float = -100.0
@export var move_distance: float = 50.0

# SOUNDS
@onready var died_sound: AudioStreamPlayer = $GameAssets/DiedSound
@onready var scored_sound: AudioStreamPlayer = $GameAssets/ScoredSound
@onready var new_high_score_sound: AudioStreamPlayer = $GameAssets/NewHighScoreSound
@onready var intro_music_sound: AudioStreamPlayer = $GameAssets/IntroMusicSound

# OTHER
@onready var replay_delay_timer: Timer = $ReplayDelayTimer

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

var can_restart: bool = false

@onready var high_scores := $GameAssets/HighScores

func _ready() -> void:
	create_obstacles()
	ship.position = rest_pos
	top_track_indicator.position = rest_pos + Vector2(75, -move_distance)
	middle_track_indicator.position = rest_pos + Vector2(75, 0)
	bottom_track_indicator.position = rest_pos + Vector2(75, move_distance)

	Events.arrived_at_meta_path.connect(_on_arrived_at_meta_path)
	Events.left_meta_path.connect(_on_left_meta_path)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return


	# OBSTACLES
	move_obstacles(_delta)
	check_recycle_obstacles()
	check_spawn_obstacles()

	# MISSILES
	for missile in active_missiles:
		missile.move(_delta)
	
	check_recycle_missiles()

	set_timer_display()

	# SHIP
	move_ship()


func stop_game(flight_completed: bool) -> void:
	alive = false
	ship.visible = false

	if not flight_completed:
		return

	pause_timer()
	replay_delay_timer.stop()
	replay_delay_timer.start()

	for obstacle in enabled_obstacles:
		obstacle.speed_tween = create_tween()
		obstacle.speed_tween.tween_property(obstacle, "speed", -3200.0, 3.0).set_ease(Tween.EASE_IN)
		pass

	for obstacle in disabled_obstacles:
		obstacle.speed_tween = create_tween()
		obstacle.speed_tween.tween_property(obstacle, "speed", -3200.0, 3.0).set_ease(Tween.EASE_IN)
		pass

	var score = points_counter.total_points
	var saved = JSBridge.save_score(score)

	var result := {"message": "score not saved :("}
	if saved:
		result = high_scores.check_add_high_score(score)

		if result["new_pb"]:
			points_counter.set_personal_best(score)

	if result["message"] == "!! NEW HIGH SCORE !!":
		new_high_score_sound.play()
	else:
		died_sound.play()

	show_game_over(result["message"])


func reset_game() -> void:
	set_in_near_miss(false)
	points_counter.reset()

	reset_obstacles()

	clear_active_missiles()

	start_game_timer()
	in_end_cutscene = false
	if cutscene_tween:
		cutscene_tween.kill()

	game_over.show_restart(false)
	print("can't restart")
	can_restart = false

	ship.position = rest_pos
	ship.visible = true

	alive = true
	reset_input()

	hide_game_over()

	Events.game_reset.emit()



func _on_replay_delay_timer_timeout() -> void:
	print("Replay delay timer finished, allowing restart")
	can_restart = true
	game_over.show_restart(true)
	

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
	elif event.is_action_pressed("shoot") and control_info.visible:
		gameplay_info.visible = true
		show_gameplay_info()
	elif event.is_action_pressed("shoot") and gameplay_info.visible:
		reset_game()
		show_game_assets()
	elif event.is_action_pressed("shoot") and alive:
		shoot()
	elif event.is_action_pressed("shoot") and not alive and can_restart:
		reset_game()
	

func move_ship() -> void:
	if not (alive or in_end_cutscene):
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
## GUI                            ##
####################################

@onready var control_info: Control = $ControlInfo
@onready var game_assets: Node2D = $GameAssets
@onready var game_over: Control = $GameOver
@onready var gameplay_info: Control = $GameplayInfo

func show_game_assets() -> void:
	control_info.visible = false
	gameplay_info.visible = false
	game_assets.visible = true

func show_control_info() -> void:
	game_assets.visible = false
	control_info.visible = true
	stop_game(false)
	reset_obstacles()
	points_counter.reset()

func hide_game_over() -> void:
	game_over.visible = false

func show_game_over(result: String) -> void:
	game_over.set_text(result)
	game_over.visible = true

func show_gameplay_info() -> void:
	control_info.visible = false
	gameplay_info.visible = true

var quiet_music_tween: Tween = null
func _on_arrived_at_meta_path(meta_path_index: int) -> void:
	if meta_path_index != 2:
		return
	show_control_info()

	intro_music_sound.volume_db = -16.0
	intro_music_sound.play()
	quiet_music_tween = create_tween()
	quiet_music_tween.tween_property(intro_music_sound, "pitch_scale", 1.0, 12.0).from(1.0)
	quiet_music_tween.tween_property(intro_music_sound, "volume_db", -80.0, 2.0).from(-16.0)


func _on_left_meta_path(_meta_path_index: int) -> void:
	show_game_assets()
	if alive:
		stop_game(true)
	else:
		stop_game(false)
	hide_game_over()
	reset_obstacles()
	points_counter.reset()

	if intro_music_sound.playing:
		intro_music_sound.stop()
	if quiet_music_tween:
		quiet_music_tween.kill()

####################################
## TIMER                          ##
####################################

@onready var game_timer: Timer = $GameTimer
@onready var game_timer_display: GameTimerDisplay = $GameAssets/GameTimerDisplay

var in_end_cutscene: bool = false
var cutscene_tween: Tween = null

func set_timer_display() -> void:
	var time_remaining = int(ceil(game_timer.time_left))
	game_timer_display.set_time_remaining(time_remaining)

func start_game_timer() -> void:
	game_timer.paused = false
	game_timer.stop()
	game_timer.start()

func pause_timer() -> void:
	game_timer.paused = true


func _on_game_timer_timeout() -> void:
	alive = false
	in_end_cutscene = true

	await get_tree().create_timer(3.0).timeout
	if alive:
		return
	cutscene_tween = create_tween()
	cutscene_tween.tween_property(ship, "position:x", off_screen_right + 500.0, 3.0).set_ease(Tween.EASE_IN)
	await cutscene_tween.finished
	stop_game(true)




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
	scored_sound.play()
	_award_near_miss_points(distance)


func award_late_near_miss_points(distance: float) -> void:
	if not alive:
		return
	scored_sound.play()
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
		game_assets.add_sibling(obstacle)
		obstacle.position.x = off_screen_right
		_disable_obstacle(obstacle)
		disabled_obstacles.append(obstacle)


# used during restart to reset obstacles 
func reset_obstacles() -> void:
	for obstacle in enabled_obstacles:
		_disable_obstacle(obstacle)
		disabled_obstacles.append(obstacle)
	enabled_obstacles.clear()
	
	for obstacle in disabled_obstacles:
		if obstacle.speed_tween:
			obstacle.speed_tween.kill()
		obstacle.speed = obstacle_speed
		obstacle.position.x = off_screen_right

# used on physics frame to check for and recycle off-screen obstacles
func check_recycle_obstacles() -> void:
	for obstacle in enabled_obstacles:
		if obstacle.position.x < off_screen_left - 100 or obstacle.position.x > off_screen_right + 100:
			_recycle_obstacle(obstacle)


# used on physics frame to check for and spawn new obstacles
func check_spawn_obstacles() -> void:
	frames_since_last_spawn += 1
	if frames_since_last_spawn >= _spawn_every_n_frames:
		frames_since_last_spawn = 0
		_spawn_obstacle()


func move_obstacles(delta: float) -> void:
	for obstacle in enabled_obstacles:
		obstacle.move(delta)


# PRIVATE METHODS
###########################


# used to recycle an obstacle that has gone off-screen
func _recycle_obstacle(obstacle: Obstacle) -> void:
	enabled_obstacles.erase(obstacle)
	_disable_obstacle(obstacle)
	disabled_obstacles.append(obstacle)


# used to disable an obstacle
func _disable_obstacle(obstacle: Obstacle) -> void:
	# obstacle.visible = false
	obstacle.hit_box.monitorable = false
	obstacle.hit_box.set_process(false)
	obstacle.physics_interpolation_mode = PhysicsInterpolationMode.PHYSICS_INTERPOLATION_MODE_OFF
	obstacle.set_deferred("position:x", off_screen_right if alive else off_screen_left)


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

	obstacle.position.x = off_screen_right if alive else off_screen_left
	obstacle.set_deferred("visible", true)
	obstacle.hit_box.set_deferred("monitorable", true)
	obstacle.hit_box.set_deferred("process", true)
	obstacle.set_deferred("physics_interpolation_mode", PhysicsInterpolationMode.PHYSICS_INTERPOLATION_MODE_ON)
	enabled_obstacles.append(obstacle)
	return obstacle


####################################
## MISSILES                       ##
####################################

@export var MissileScene: PackedScene

var active_missiles: Array[Missile] = []

func shoot() -> void:
	if active_missiles.size() >= 3:
		return
		
	var missile := MissileScene.instantiate()
	active_missiles.append(missile)
	missile.position = ship.position + Vector2(50, 0)
	game_assets.add_sibling(missile)

func check_recycle_missiles() -> void:
	for missile in active_missiles:
		if missile.position.x > off_screen_right + 100 or missile.position.x < off_screen_left - 100:
			_recycle_missile(missile)

func clear_active_missiles() -> void:
	for missile in active_missiles:
		missile.queue_free()
	active_missiles.clear()


func _recycle_missile(missile: Missile) -> void:
	active_missiles.erase(missile)
	missile.queue_free()

####################################
## COLLISIONS                     ##
####################################

func _on_ship_area_entered(area: Area2D) -> void:
	if (area.name == "HitBox"):
		if alive:
			stop_game(true)
		return

	if (area.name == "NearMissBox"):
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


func _on_projectile_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.
