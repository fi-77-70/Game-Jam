extends Node3D
@onready var timer = $VisionTimer
@onready var jumpscare = get_node("Jumpscare")

func _on_jumpscare_finished():
	get_tree().change_scene_to_file("res://Scenes/YouDied.tscn")
	queue_free()

func trigger_jumpscare(player):
	player.set_physics_process(false)
	jumpscare.play()
	timer.start(1)
	timer.connect("timeout", Callable(self, "_on_jumpscare_finished"))

func _on_vision_timer_timeout() -> void:
	var overlaps = $FOV.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				var PlayerPosition = overlap.global_transform.origin
				$VisionRaycast.look_at(PlayerPosition, Vector3.UP)
				
				if $VisionRaycast.is_colliding():
					var collider = $VisionRaycast.get_collider()
					
					if collider.name == "Player":
						trigger_jumpscare(get_tree().get_nodes_in_group("player")[0])
