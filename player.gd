extends CharacterBody3D

const SPEED = 5.0
const CROUCH_SPEED = 2
const NORMAL_HEIGH = 1
const CROUCH_HEIGH = 0.5
const JUMP_VELOCITY = 4.5
const GRAVITY = Vector3(0, -9.8, 0)
const MOUSE_SENSE = 0.2
const VERTICAL_LIMIT = 89.0

#const GRAB_DISTANCE = 1.00
#const THROW_FORCE = 10.0

var rotation_x = 0.0
#var grabbed_object = null

var is_crouching = false
var original_heigh = 0.0
var original_radius = 0.0

var crouch_mode = "click"
var crouch_toggle_click = true

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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI awawda  a tions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	move_and_slide()

@onready var heyo = get_node("../Sound/Heyo")
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
	elif Input.is_action_just_released("crouch"):
		crouch()

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

func crouch():
	is_crouching = !is_crouching
	var capsule = $CollisionShape3D.shape

	if is_crouching:
		capsule.height = CROUCH_HEIGH
		capsule.radius *= 0.5
	else:
		capsule.height = original_heigh
		capsule.radius += original_radius

func set_crouch_mode(mode: String):
	crouch_mode = mode
	crouch_toggle_click = false
