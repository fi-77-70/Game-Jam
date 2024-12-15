extends Node3D

@onready var patrol_timer = $VisionTimer
@onready var jumpscare = get_node("Jumpscare")
@onready var detection_timer = Timer.new()  # Timer for delayed detection

var rotation_points = [Vector3(0, 0, 0), Vector3(0, 90, 0), Vector3(0, 180, 0), Vector3(0, -90, 0)]
var curr_rot_index = 0
var is_patrolling = true
var detecting_player = false  # To track if the enemy is already detecting the player

func _ready():
	# Add and configure the detection timer
	add_child(detection_timer)
	detection_timer.wait_time = 1.0  # 1-second delay
	detection_timer.one_shot = true
	detection_timer.connect("timeout", Callable(self, "_on_detection_timeout"))

	# Start the patrol timer
	patrol_timer.connect("timeout", Callable(self, "_on_patrol_timer_timeout"))
	patrol_timer.start(3)

func patrol_rotation():
	if is_patrolling:
		var target_rotation = rotation_points[curr_rot_index]
		curr_rot_index = (curr_rot_index + 1) % rotation_points.size()
		var tween = get_tree().create_tween()
		tween.tween_property(self, "rotation_degrees", target_rotation, 1.0)

func _on_patrol_timer_timeout():
	patrol_rotation()

func _process(delta):
	# Continuously check for player detection
	if is_patrolling and not detecting_player:
		check_for_player()

func check_for_player():
	var overlaps = $FOV.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				var PlayerPosition = overlap.global_transform.origin
				$VisionRaycast.look_at(PlayerPosition, Vector3.UP)
				if $VisionRaycast.is_colliding():
					var collider = $VisionRaycast.get_collider()
					if collider.name == "Player" and not detecting_player:
						start_detection(overlap)  # Pass the player node

func start_detection(player):
	detecting_player = true
	detection_timer.start()  # Start a 1-second delay before the jumpscare
	$VisionRaycast.look_at(player.global_transform.origin, Vector3.UP)

func _on_detection_timeout():
	var overlaps = $FOV.get_overlapping_bodies()
	for overlap in overlaps:
		if overlap.name == "Player":
			trigger_jumpscare(overlap)
			return

	detecting_player = false  # Reset detection if player is no longer in view

func trigger_jumpscare(player):
	is_patrolling = false
	detecting_player = false
	patrol_timer.stop()
	player.set_physics_process(false)
	jumpscare.play()
	patrol_timer.start(1)
	patrol_timer.connect("timeout", Callable(self, "_on_jumpscare_finished"))

func _on_jumpscare_finished():
	get_tree().change_scene_to_file("res://Scenes/YouDied.tscn")
	queue_free()
