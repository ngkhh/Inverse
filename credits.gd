extends Control

func _on_exit_button_pressed() -> void:
	print("exiting")
	var menu_screen = load("res://menu.tscn")
	get_tree().change_scene_to_packed(menu_screen)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
