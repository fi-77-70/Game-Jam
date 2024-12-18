extends CharacterBody3D

@onready var nav:= $NavigationAgent3D

@onready var randomPos = Vector3(randf_range(-80, 10), 0, randf_range(-80, 10))

var wanderTimer = 0.0

var speed = 0.1

var stuck_timer = 0.0 
var stuck_threshold = 1.0 


func _process(delta):
	wandering(delta)
	var next_position = nav.get_next_path_position()
	if next_position:
		var direction = (-(next_position - global_transform.origin)).normalized()
		self.look_at(global_transform.origin + direction, Vector3.UP)
		self.rotate_y(deg_to_rad(self.rotation.y * 5))
		self.velocity = (next_position - transform.origin).normalized() * speed * delta
		get_node("./AnimationPlayer").play("Armature|walking_man|baselayer")
	
		var collision_info = move_and_collide(velocity)
		
		if collision_info:
			stuck_timer += delta
			if stuck_timer >= stuck_threshold:
				get_node("./AnimationPlayer").stop()
				velocity = Vector3() # Stop movement
		else:
			stuck_timer = 0.0

func wandering(delta):
	nav.target_position = randomPos
	if (abs(randomPos.x - global_position.x) <= 5 and abs(randomPos.z - global_position.z) <= 5) or wanderTimer <= 0:
		randomPos = Vector3(randf_range(-80, 10), 0, randf_range(-80, 10))
		wanderTimer = 5.0
	wanderTimer -= delta
