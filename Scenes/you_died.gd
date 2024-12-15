extends Control
@onready var timer = $Timer

func _on_end():
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(4)
	timer.connect("timeout", Callable(self, "_on_end"))
