extends Position3D

var angle_x = -30;
var angle_y = 0;

var _angle_x = -50;
var _angle_y = 0;

var move_to;

func _ready():
	move_to = transform.origin

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("ROTATE_TERRAIN"):
			# rotate by motion
			angle_x -= event.relative.y;
			angle_y -= event.relative.x;
			
			if angle_x > -5:
				angle_x = -5
			elif angle_x < -90:
				angle_x = -90
		elif Input.is_action_pressed("MOVE_TERRAIN"):
			var left_right = transform.basis.x
			left_right.y = 0.0
			left_right = left_right.normalized()
			
			move_to += left_right * event.relative.x * -0.1
			
			var front_back = transform.basis.z
			front_back.y = 0.0
			front_back = front_back.normalized()
			
			move_to += front_back * event.relative.y * -0.1
		elif Input.is_key_pressed(KEY_CONTROL):
			var cam_origin = $Camera.transform.origin
			cam_origin.z = clamp(cam_origin.z + (event.relative.y * 0.1), 10.0, 1000.0)
			$Camera.transform.origin = cam_origin

func _process(delta):
	if angle_x != _angle_x or angle_y != _angle_y:
		_angle_x += (angle_x - _angle_x) * delta * 10.0;
		_angle_y += (angle_y - _angle_y) * delta * 10.0;
		
		var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
		basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
		transform.basis = basis
	
	if move_to != transform.origin:
		transform.origin += (move_to - transform.origin) * delta * 10.0;