extends Control

@export var main_game_scene: PackedScene = preload("res://main.tscn")


func _on_start_button_pressed() -> void:
	if main_game_scene:
		get_tree().change_scene_to_packed(main_game_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	print("go to credit scene")
	var credits_screen = load("res://credits.tscn")
	get_tree().change_scene_to_packed(credits_screen)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
