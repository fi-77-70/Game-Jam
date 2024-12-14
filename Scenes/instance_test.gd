extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scene = preload("res://assets/biped/Animation_Gangnam_Groove_withSkin.glb")
	var instance = scene.instantiate()
	add_child(instance)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
