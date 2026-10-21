extends Node2D

@onready var player = $Player
@onready var obstacles = $Obstacles
@onready var road = $Road
@onready var score_label = $UI/ScoreLabel
@onready var speed_label = $UI/SpeedLabel
@onready var game_over_screen = $UI/GameOverScreen
@onready var final_score_label = $UI/GameOverScreen/VBoxContainer/FinalScoreLabel
@onready var spawn_timer = $SpawnTimer
@onready var score_timer = $ScoreTimer

var obstacle_scene = preload("res://scenes/obstacle.tscn")
var game_running = false
var score = 0
var speed = 0
var base_speed = 200
var max_speed = 600
var difficulty_multiplier = 1.0

const ROAD_LEFT = 80
const ROAD_RIGHT = 400
const LANES = [120, 200, 280, 360]

func _ready():
	start_game()

func start_game():
	game_running = true
	score = 0
	speed = base_speed
	difficulty_multiplier = 1.0
	
	# Clear existing obstacles
	for obs in obstacles.get_children():
		obs.queue_free()
	
	player.position = Vector2(240, 700)
	player.reset()
	
	game_over_screen.visible = false
	spawn_timer.start()
	score_timer.start()
	
	update_ui()

func _process(delta):
	if not game_running:
		return
	
	# Update road scrolling effect
	road.scroll(speed * delta)
	
	# Move obstacles
	for obs in obstacles.get_children():
		obs.position.y += speed * delta
		if obs.position.y > 850:
			obs.queue_free()
			score += 10
	
	# Increase difficulty over time
	difficulty_multiplier = 1.0 + (score / 1000.0)
	var target_speed = min(base_speed + (score * 0.5), max_speed)
	speed = lerp(speed, target_speed, delta * 0.5)
	
	update_ui()
	check_collisions()

func update_ui():
	score_label.text = "Score: %d" % score
	speed_label.text = "Speed: %d" % int(speed / 10)

func check_collisions():
	for obs in obstacles.get_children():
		if player.collides_with(obs):
			game_over()
			return

func game_over():
	game_running = false
	spawn_timer.stop()
	score_timer.stop()
	player.crash()
	
	final_score_label.text = "Final Score: %d" % score
	game_over_screen.visible = true

func _on_spawn_timer_timeout():
	if not game_running:
		return
	
	spawn_obstacle()
	
	# Adjust spawn rate based on difficulty
	var new_wait = max(0.5, 1.5 - (difficulty_multiplier - 1.0) * 0.3)
	spawn_timer.wait_time = new_wait

func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	
	# Pick random lane
	var lane_x = LANES[randi() % LANES.size()]
	obstacle.position = Vector2(lane_x, -50)
	
	# Random rotation animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(obstacle.get_node("Sprite"), "rotation", PI * 2, 2.0)
	
	obstacles.add_child(obstacle)

func _on_score_timer_timeout():
	if game_running:
		score += 1

func _on_restart_pressed():
	start_game()
