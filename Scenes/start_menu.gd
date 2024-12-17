extends Control

@onready var animation_player = $AnimationPlayer
@onready var menu = $"/root/StartMenu"

func _ready():
	$Buttons/StartButton.connect("pressed", Callable(self, "_on_start_button_pressed"))

func _on_start_button_pressed():
	animation_player.play("fade_to_black")
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		menu.visible = false
		animation_player.play("fade_to_normal")
		get_tree().change_scene_to_file("res://Scenes/Level1_night.tscn")
