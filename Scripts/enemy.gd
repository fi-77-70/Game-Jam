
extends CharacterBody3D

@export var SPEED = 5.0

@export var rotate_speed = 5.0

var player = null
var map_synchronized = false

func _ready() -> void:
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
