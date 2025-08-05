extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player_camera = $Camera2D
@onready var particle_system_scene = preload("res://unitys_particle_system.tscn")
@onready var collision_shape = $CollisionShape2D

@onready var jump_sound = $Jump
@onready var death_sound = $Death
@onready var step_sound = $Step
@onready var teleport_sound = $Teleport
@onready var flip_sound = $Flip

signal flips_changed(flips_remaining)

var max_flips = 2
var current_flips = max_flips
var current_spawn_point: Marker2D

const SPEED = 150.0
const JUMP_VELOCITY = -220.0
const BASE_GRAVITY = 700.0
const CAMERA_ZOOM = 4
var is_dead = false
var current_gravity = BASE_GRAVITY
var can_flip_gravity = true

func _ready() -> void:
	flips_changed.emit(current_flips)
	if not current_spawn_point:
		var spawn_points = get_tree().get_nodes_in_group("spawn_points")
		if not spawn_points.is_empty():
			current_spawn_point = spawn_points[0]
		if not current_spawn_point:
			printerr("Initial SpawnPoint not found in scene")
	flips_changed.emit(current_flips)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity += get_gravity() * delta
		global_position += velocity * delta
		
	else:
		if Input.is_action_just_pressed("flip_gravity") and can_flip_gravity:
			flip_gravity()
			
		
		velocity += Vector2(0, current_gravity) * delta

		if Input.is_action_just_pressed("jump"):
			if is_on_ceiling() or is_on_floor():
				velocity.y = JUMP_VELOCITY * sign(current_gravity)
				jump_sound.play()
		
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
			if not step_sound.playing && (is_on_ceiling() or is_on_floor()):
				step_sound.play()
		else:
			velocity.x = move_toward(velocity.x, 0, 65)
		
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
		elif velocity.x < 0:
			animated_sprite_2d.flip_h = true
		
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
		velocity.y = 10 * sign(current_gravity)
		animated_sprite_2d.flip_v = not animated_sprite_2d.flip_v
		can_flip_gravity = false
		flips_changed.emit(current_flips)
		flip_sound.play()
		$GravityFlipTimer.start()
	
func _on_gravity_flip_timer_timeout() -> void:
	can_flip_gravity = true

func handle_death():
	if is_dead:
		return
	
	Deathcounter.increment_death_count()
	
	is_dead = true
	collision_shape.disabled = true
	
	var current_camera_position = player_camera.global_position
	var death_camera = Camera2D.new()
	get_parent().add_child(death_camera)
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
	death_sound.play()
	
	
	velocity.y = JUMP_VELOCITY
	velocity.x = 0
	current_gravity = BASE_GRAVITY
	animated_sprite_2d.flip_v = false
	
	var death_cleanup_timer = Timer.new()
	death_cleanup_timer.one_shot = true
	death_cleanup_timer.wait_time = 2.0
	get_parent().add_child(death_cleanup_timer)
	
	death_cleanup_timer.timeout.connect(func():
		_clean_up_death(death_camera)
		respawn()
		death_cleanup_timer.queue_free()
		)
	death_cleanup_timer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		handle_death()

func _on_area_2d_body_entered2(body: Node2D) -> void:
	handle_death()

func set_flips(new_max_flips: int) -> void:
	max_flips = new_max_flips
	current_flips = max_flips
	flips_changed.emit(current_flips)

func respawn() -> void:
	is_dead = false
	collision_shape.disabled = false
	
	if current_spawn_point:
		var current_level_node = current_spawn_point.get_parent()
		call_deferred("set_global_position", current_spawn_point.global_position)
		velocity = Vector2.ZERO
		
		if current_level_node and "level_max_flips" in current_level_node:
			set_flips(current_level_node.level_max_flips)

func _clean_up_death(camera_to_free: Camera2D) -> void:
	player_camera.make_current()
	if is_instance_valid(camera_to_free):
		camera_to_free.queue_free()
