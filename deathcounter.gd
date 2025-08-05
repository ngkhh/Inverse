extends Node

var death_count = 0

signal death_count_updated(new_count)

func increment_death_count():
	death_count += 1
	death_count_updated.emit(death_count)




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
