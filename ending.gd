extends CenterContainer

func _on_exit_button_pressed() -> void:
	print("go to title")
	
	var title_screen = load("res://menu.tscn")
	
	if title_screen:
		print("going")
		get_tree().change_scene_to_packed(title_screen)
	else:
		printerr("Title screen scene is not set or is invalid!")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
