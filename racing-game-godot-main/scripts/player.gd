extends CharacterBody2D

@onready var trail_particles = $TrailParticles

var speed = 300
var steer_speed = 400
var velocity = Vector2.ZERO
var crashed = false

const ROAD_LEFT = 60
const ROAD_RIGHT = 420

func _ready():
	reset()

func reset():
	velocity = Vector2.ZERO
	crashed = false
	trail_particles.emitting = true
	rotation = 0

func _physics_process(delta):
	if crashed:
		return
	
	var input_dir = Vector2.ZERO
	
	# Handle input
	if Input.is_action_pressed("move_left"):
		input_dir.x = -1
	if Input.is_action_pressed("move_right"):
		input_dir.x = 1
	if Input.is_action_pressed("accelerate"):
		input_dir.y = -1
	if Input.is_action_pressed("brake"):
		input_dir.y = 1
	
	# Calculate velocity
	velocity.x = input_dir.x * steer_speed
	velocity.y = input_dir.y * speed * 0.5
	
	# Apply movement
	move_and_slide()
	
	# Manual position clamping
	position.x = clamp(position.x, ROAD_LEFT + 30, ROAD_RIGHT - 30)
	position.y = clamp(position.y, 100, 750)
	
	# Tilt effect when steering
	var target_rotation = input_dir.x * 0.15
	rotation = lerp(rotation, target_rotation, delta * 10)
	
	# Update particles
	trail_particles.emitting = true

func crash():
	crashed = true
	trail_particles.emitting = false
	
	# Crash animation
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "rotation", rotation + PI * 2, 0.5)
	tween.tween_property(self, "modulate", Color(1, 0.3, 0.3, 0.5), 0.3)

func collides_with(obstacle: Node2D) -> bool:
	if crashed:
		return false
	
	var dist = global_position.distance_to(obstacle.global_position)
	return dist < 35
