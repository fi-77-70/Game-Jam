extends Control

func _ready():
	$Buttons/StartButton.connect("pressed", Callable(self, "_on_start_button_pressed"))
	$Buttons/OptionsButton.connect("pressed", Callable(self, "_on_options_button_pressed"))
	$Buttons/QuitButton.connect("pressed", Callable(self, "_on_quit_button_pressed"))

func _on_start_button_pressed():
	print("START GAME")
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")

func _on_options_button_pressed():
	print("OPTIONS")
	get_tree().change_scene("res://options.tscn")
	
func _on_quit_button_pressed():
	print("QUIT GAME")
	get_tree().quit()
