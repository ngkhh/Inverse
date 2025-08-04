extends Area2D
@onready var teleport_timer = $Timer
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
		teleport_timer.start()


func _on_timer_timeout() -> void:
	print("teleporting")
	var player_node = get_tree().get_first_node_in_group("Player")
	var next_level = get_tree().get_first_node_in_group(destination_level)
	var spawn_point = next_level.get_node("SpawnPoint")
	
	if player_node and spawn_point:
		player_node.global_position = spawn_point.global_position

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		teleport_timer.stop()
