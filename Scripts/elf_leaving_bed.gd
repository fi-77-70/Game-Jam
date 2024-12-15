extends CharacterBody3D

var speed = 1
var accel = 1

@onready var nav: NavigationAgent3D = $NavigationAgent3D

var has_reached_target = false

func _physics_process(delta):
	if !has_reached_target:
		nav.target_position = Vector3(0, 0, -11)
		var direction = nav.get_next_path_position() - global_position
		
		if direction.length() < 0.5:  # Consider a small distance threshold to stop
			has_reached_target = true  # Stop further processing
			return
		
		direction = direction.normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)
		move_and_collide(velocity)
