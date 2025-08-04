extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player_camera = $Camera2D
@onready var particle_system_scene = preload("res://unitys_particle_system.tscn")
@onready var death_timer = $Timer
@onready var collision_shape = $CollisionShape2D

signal flips_changed(flips_remaining)

var max_flips = 3
var current_flips = max_flips

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const BASE_GRAVITY = 980.0
const CAMERA_ZOOM = 4
var is_dead = false
var death_camera = Camera2D.new()
var current_gravity = BASE_GRAVITY
var can_flip_gravity = true

func _ready() -> void:
	flips_changed.emit(current_flips)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity += get_gravity() * delta
		global_position += velocity * delta
		
	else:
		if Input.is_action_just_pressed("flip_gravity") and can_flip_gravity:
			flip_gravity()
		
		velocity += Vector2(0, current_gravity) * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump"):
			if is_on_ceiling() or is_on_floor():
				velocity.y = JUMP_VELOCITY * sign(current_gravity)
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 65)
		
		
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
		elif velocity.x < 0:
			animated_sprite_2d.flip_h = true
		#up_direction = Vector2.UP * -sign(current_gravity)
		move_and_slide()
		if current_gravity > 0:
			if not is_on_floor():
				animated_sprite_2d.play("Jump")
			elif direction:
				animated_sprite_2d.play("Walk")
			else: 
				animated_sprite_2d.play("Idle")
		else:
			if not is_on_ceiling():
				animated_sprite_2d.play("Jump")
			elif direction:
				animated_sprite_2d.play("Walk")
			else: 
				animated_sprite_2d.play("Idle") 

func flip_gravity():
	if current_flips > 0:
		current_gravity *= -1
		current_flips -= 1
		velocity.y = 10*sign(current_gravity)
		animated_sprite_2d.flip_v = not animated_sprite_2d.flip_v
		can_flip_gravity = false
		flips_changed.emit(current_flips)
		$GravityFlipTimer.start()
	
func _on_gravity_flip_timer_timeout() -> void:
	can_flip_gravity = true

func handle_death():
	if is_dead:
		return
	
	is_dead = true
	
	collision_shape.disabled = true
	
	var current_camera_position = player_camera.global_position
	get_tree().get_root().add_child(death_camera)
	death_camera.global_position = current_camera_position
	death_camera.zoom.y = CAMERA_ZOOM
	death_camera.zoom.x = CAMERA_ZOOM
	death_camera.make_current()
	
	animated_sprite_2d.play("Death")
	var particles = particle_system_scene.instantiate()
	particles.global_position = animated_sprite_2d.global_position
	get_parent().add_child(particles)
	particles.restart()
	particles.finished.connect(particles.queue_free)
	
	velocity.y = JUMP_VELOCITY
	velocity.x = 0
	
	death_timer.start(2)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		handle_death()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	player_camera.make_current()
	death_camera.free()


func _on_area_2d_body_entered2(body: Node2D) -> void:
	handle_death()
