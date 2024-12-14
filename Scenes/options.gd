extends Control

@onready var audio_slider = $Buttons/AudioSettings/AudioSlider

func _ready():
	# Set default values
	audio_slider.value = AudioServer.get_bus_volume_db(0)  # Get current audio volume

	# Connect signals
	audio_slider.connect("value_changed", Callable(self, "_on_audio_slider_changed"))
	$Buttons/BackButton.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_audio_slider_changed(value):
	# Adjust audio volume (convert slider value to decibels)
	var db_value = -80 + (value * 0.8)  # Map 0-100 to -80 to 0 dB
	AudioServer.set_bus_volume_db(0, db_value)

func _on_back_button_pressed():
	print("Returning to main menu")
	get_tree().change_scene("res://StartMenu.tscn")  # Navigate back to start menu
