
extends CharacterBody3D

var isVisible = true

@onready var nav:= $NavigationAgent3D

@onready var randomPos = Vector3(randf_range(-80, 10), position.y, randf_range(-80, 10))

var wanderTimer = 0.0

var speed = 1.0
var lastPos: Vector3

var stuck_timer = 0.0 
var stuck_threshold = 1.0 

@export var SPEED = 5.0

@export var rotate_speed = 5.0

var player = null
var map_synchronized = false
var isChasing = false

func _ready() -> void:
	update_visibility()
	# Get the player node (assuming there's only one player in the "player" group)
	player = get_tree().get_nodes_in_group("player")[0]

	# Connect to the NavigationServer's map_changed signal to be notified when the map is synchronized
	NavigationServer3D.connect("map_changed", Callable(self, "_on_map_changed"))

func _on_map_changed(map_rid: RID) -> void:
	# This function is called when the navigation map is updated.
	# The signal passes an argument `map_rid` which is of type RID.
	map_synchronized = true
	print("Navigation map is synchronized, ready for pathfinding. Map RID: ", map_rid)

func _physics_process(delta: float) -> void:
	if isChasing:
		if player:
			if (player.global_transform.origin != self.global_transform.origin):
				self.look_at(player.global_transform.origin, Vector3.UP)
				self.rotate_y(deg_to_rad(self.rotation.y * rotate_speed))
			if map_synchronized:
				# Set the target position of the NavigationAgent3D to the player's position
				$NavigationAgent3D.set_target_position(player.global_position)
				get_node("./Enemy/AnimationPlayer").play("Armature|walking_man|baselayer")
				# Get the next path position and move towards it
				var next_position = $NavigationAgent3D.get_next_path_position()
				self.velocity = (next_position - transform.origin).normalized() * SPEED * delta
				# Perform the movement
				move_and_collide(velocity)
			else:
				print("Waiting for navigation map synchronization.")
	else:
		wandering(delta)
		var next_position = nav.get_next_path_position()
		if next_position:
			var direction = (next_position - global_transform.origin).normalized()
			self.look_at(global_transform.origin + direction, Vector3.UP)
			self.rotate_y(deg_to_rad(self.rotation.y * 5))
			self.velocity = (next_position - transform.origin).normalized() * speed * delta
			get_node("./Enemy/AnimationPlayer").play("Armature|walking_man|baselayer")
		
			var collision_info = move_and_collide(velocity)
			
			if collision_info:
				stuck_timer += delta
				if stuck_timer >= stuck_threshold:
					get_node("./Enemy/AnimationPlayer").stop()
					velocity = Vector3() # Stop movement
			else:
				stuck_timer = 0.0


func wandering(delta):
	nav.target_position = randomPos
	if (abs(randomPos.x - global_position.x) <= 5 and abs(randomPos.z - global_position.z) <= 5) or wanderTimer <= 0:
		randomPos = Vector3(randf_range(-80, 10), position.y, randf_range(-80, 10))
		wanderTimer = 5.0
	wanderTimer -= delta

func update_visibility():
	isVisible = GlobalManager.instance.get_global_condition()
	if not isVisible:
		queue_free()

func _on_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		isChasing = true
	else:
		isChasing = false


func _on_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		isChasing = false
	else:
		isChasing = true


func _on_dead_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("DEAD MDF")
