extends Area2D
@onready var teleport_timer = $Timer
@onready var teleport_sound = $TeleportSound

@export var ending :PackedScene = preload("res://Ending.tscn")
@export var destination_level = "Level 2"

var level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if destination_level != "End":
			teleport_sound.play()
			teleport_timer.start()
		else:
			_on_timer_timeout()


func _on_timer_timeout() -> void:
	print("teleporting")
	var player_node = get_tree().get_first_node_in_group("Player")
	var next_level = get_tree().get_first_node_in_group(destination_level)
	
	if destination_level != "End":
		if player_node and next_level:
			var spawn_point = next_level.get_node_or_null("SpawnPoint")
			
			if spawn_point:
				player_node.current_spawn_point = spawn_point
				player_node.global_position = spawn_point.global_position
				player_node.set_flips(next_level.level_max_flips)
				
	elif  destination_level == "End":
		print("teleporting to end screen")
		get_tree().change_scene_to_packed(ending)
	else:
		printerr("Teleport failed: Invalid level")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not teleport_timer.is_stopped():
			teleport_timer.stop()
			teleport_sound.stop()
	
