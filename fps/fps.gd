extends KinematicBody
# all the var's copy it down.
var speed 
var de_speed = 7
var run_speed = 14
var crouch_speed = 20

const accel_default = 8
const accel_air = 1
onready var accel = accel_default

var gravity = 9.8
var jump = 5

var mouse_sense = 0.1
var snap

var dir = Vector3()
var vel = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()
# crouch height 
var d_height = 1.5
var c_height = 0.4
# all the onready var's copy it down.
onready var head = $head
onready var camera = $head/Camera
onready var pcap = $CollisionShape
onready var ray = $RayCast
#for detection 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	# to get the input.
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _physics_process(delta):
	#movement check
	var raying = false
	speed = de_speed
	dir = Vector3.ZERO
	#get keyboard input
	if Input.is_action_pressed("sprint"):
		speed = run_speed
	if Input.is_action_pressed("sprint") and  Input.is_action_pressed("crouch"):
		speed = de_speed
	#movement
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("s") - Input.get_action_strength("w")
	var h_input = Input.get_action_strength("d") - Input.get_action_strength("a")
	dir = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	if ray.is_colliding():
		raying = true
	if raying:
		gravity_vec -= Vector3.UP * jump
		# the crouch function copy it down
	if Input.is_action_pressed("crouch"):
		pcap.shape.height -= crouch_speed * delta
	elif not raying:
		pcap.shape.height += crouch_speed * delta
	pcap.shape.height =  clamp(pcap.shape.height, c_height,d_height)
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = accel_default
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = accel_air
		gravity_vec += Vector3.DOWN * gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	# the important make it move part.
	vel = vel.linear_interpolate(dir * speed, accel * delta)
	movement = vel + gravity_vec
	move_and_slide_with_snap(movement, snap, Vector3.UP)
