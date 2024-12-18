extends CharacterBody3D

@export var player_scene: PackedScene
@onready var heyo = $Sound/Heyo

# NORMAL CONTROLS INIT
const JUMP_VELOCITY = 1.5
const NORMAL_SPEED = 1.0
const RUN_SPEED = 2.0
const GRAVITY = Vector3(0, -9.8, 0)

# CROUCH CONTROLS INIT
const CROUCH_TRANSITION_SPEED = 4
const NORMAL_HEIGH = 1.0
const CROUCH_HEIGH = 0.5

#MOUSE ROTATE INIT
const MOUSE_SENSE = 0.2
const VERTICAL_LIMIT = 89.0

#const GRAB_DISTANCE = 1.00
#const THROW_FORCE = 10.0

#CROUCH INIT
var is_crouching = false
var original_heigh = 0.0
var original_radius = 0.0
var crouch_mode = "click"
var crouch_toggle_click = true
var target_height = NORMAL_HEIGH

#ROTATE INIT
var rotation_x = 0.0

#RUN INIT
var speed = 1.0
#var grabbed_object = null
#@onready var camera = $Node3D/Camera3D
#@onready var raycast = $Node3D/Camera3D/RayCast3D

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var capsule = $CollisionShape3D.shape
	original_heigh = capsule.height
	original_radius = capsule.radius
#	raycast.enabled = true

#func _process(delta):
#	if grabbed_object:
#		update_grabbed_object_position()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("run") and is_on_floor() and Input.is_action_pressed("move_forward"):
		speed = RUN_SPEED
	if Input.is_action_just_released("run"):
		speed = NORMAL_SPEED
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI awawda  a wtions with custom gameplay actions.
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

	update_crouch(delta)
	move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("play_heyo"):
		heyo.play()
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSE))
		rotation_x += -event.relative.y * MOUSE_SENSE
		rotation_x = clamp(rotation_x, -VERTICAL_LIMIT, VERTICAL_LIMIT)
		$Node3D/Camera3D.rotation_degrees.x = rotation_x
	if Input.is_action_just_pressed("crouch"):
		crouch()
	if Input.is_action_just_released("crouch"):
		release_crouch()

#	if Input.is_action_just_pressed("grab"):
#		if grabbed_object:
#			throw_object()
#		else:
#			try_grab_object()

#func try_grab_object():
#	raycast.force_raycast_update()
#	if raycast.is_colliding():
#		var collider = raycast.get_collider()
#		if collider:
#			grab_object(collider)

#func grab_object(object):
#	grabbed_object = object
#	if grabbed_object:
#		grabbed_obkect.set_mode(RigidBody3D.MODE_KINEMATIC)
#		grabbed_object.set_physics_process(false)
#		grabbed_oject.parent = camera

#func release_object():
#	if grabbed_object:
#		grabbed_object.parent = get_tree().root
#		grabbed_object.set_mode(RigidBody3D.MODE_RIGID)
#		grabbed_object.set_physics_process(true)
#		graabbed_object = null

#func update_grabbed_object_position():
#	if grabbed_object:
#		grabbed_object.global_transform.origin = camera.global_transform.origin + camera.global_transform.basis.z * GRAB_DISTANCE
		
#func throw_object():
#	if grabbed_object:
#		release_object()
#		var throw_vector = camera.global_transform.basis.z * THROW_FORCE
#		grabbed_object.apply_impulse(Vector3.ZERO, throw_vector)

# CROUCH FUNCTIONSw
func crouch():
	is_crouching = true
	target_height = CROUCH_HEIGH
	
func release_crouch():
	is_crouching = false;
	target_height = NORMAL_HEIGH

func update_crouch(delta: float):
	var capsule = $CollisionShape3D.shape
	# Smoothly interpolate the height of the collision shape
	capsule.height = lerp(capsule.height, target_height, CROUCH_TRANSITION_SPEED * delta)
	capsule.radius = lerp(capsule.radius, original_radius * (CROUCH_HEIGH if is_crouching else NORMAL_HEIGH), CROUCH_TRANSITION_SPEED * delta)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemys"):
		get_tree().change_scene_to_file("res://Scenes/YouDied.tscn")
	pass # Replace with function body.


func _on_render_sphere_body_entered(body: Node3D) -> void:
	if body.is_in_group("render"):
		if body.has_method("set_visible"):
			body.visible = true
		else:
			print("FUCKOFF!")


func _on_render_sphere_body_exited(body: Node3D) -> void:
	if body.is_in_group("render"):
		body.visible = false
