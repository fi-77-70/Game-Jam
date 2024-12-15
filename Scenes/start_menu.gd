extends Control

func _ready():
	$Buttons/StartButton.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed():
	print("START GAME")
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")
