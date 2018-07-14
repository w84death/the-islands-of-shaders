extends Position3D

export var rotate_speed = 1.0;
export var move_speed = 1.0;
export var move_speed_lr = 0.5;
export var move_speed_fb = 1.5;
export var terrain_height = 256;
export var water_height = 52;
export var map_size = Vector2(2048, 2048);
const DEADZONE = 0.15;

var angle_x = 0;
var angle_y = 0;

var _angle_x = -24;
var _angle_y = 0;

var height_map;
var move_to;
var w = 0
var axis_value;

func _ready():
	move_to = transform.origin
	var minimap = get_node("../GUI/demo/minimap/map")
	var tex = minimap.get_texture()
	height_map = tex.get_data()

func _input(event):
	if Input.is_action_pressed("ui_left"):
		angle_y += rotate_speed
	if Input.is_action_pressed("ui_right"):
		angle_y -= rotate_speed
	if Input.is_action_pressed("ui_up"):
		var front_back = transform.basis.z
		front_back.y = 0.0
		front_back = front_back.normalized()
		move_to -= front_back * move_speed;
	if Input.is_action_pressed("ui_down"):
		var front_back = transform.basis.z
		front_back.y = 0.0
		front_back = front_back.normalized()
		move_to += front_back * move_speed;

func _process(delta):
	if angle_x != _angle_x or angle_y != _angle_y:
		_angle_x += (angle_x - _angle_x) * delta * 10.0;
		_angle_y += (angle_y - _angle_y) * delta * 10.0;

		var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
		basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
		transform.basis = basis
		
	if move_to != transform.origin:
		var pos = Vector2(int(1024+transform.origin.x), int(1024+transform.origin.z));
		move_to.y = terrain_height * get_height(pos).r
		if move_to.y < water_height:
			move_to.y = water_height
		transform.origin += (move_to - transform.origin) * delta * 10.0
	
func _physics_process(delta):
	for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
		axis_value = Input.get_joy_axis(0, axis)
		var axis_abs = abs(axis_value)
		if axis_abs > DEADZONE:
			# ROTATE LEFT - RIGHT
			if axis == JOY_ANALOG_RX:
				if axis_value > 0:
					angle_y -= rotate_speed * axis_abs
				else:
					angle_y += rotate_speed * axis_abs
					
			# ROTATE ..THE OTEHR WAY :P
			if axis == JOY_ANALOG_RY:
				if axis_value > 0:
					if angle_x > -25:
						angle_x -= rotate_speed * axis_abs
				else:
					if angle_x < 25:
						angle_x += rotate_speed * axis_abs

			# MOVE LEFT - RIGHT
			if axis == JOY_ANALOG_LX:
				if axis_value < 0:
					var left_right = transform.basis.x
					left_right.y = 0.0
					left_right = left_right.normalized()
					move_to -= left_right * move_speed_lr * axis_abs;
				else:
					var left_right = transform.basis.x
					left_right.y = 0.0
					left_right = left_right.normalized()
					move_to += left_right * move_speed_lr * axis_abs;

			# MOVE FRONT - BACK
			if axis == JOY_ANALOG_LY:
				if axis_value < 0:
					var front_back = transform.basis.z
					front_back.y = 0.0
					front_back = front_back.normalized()
					move_to -= front_back * move_speed_fb * abs(axis_value);
				else:
					var front_back = transform.basis.z
					front_back.y = 0.0
					front_back = front_back.normalized()
					move_to += front_back * move_speed_fb * abs(axis_value);

func get_height(pos):
	var px = Color(0,0,0);
	if pos.x >= 0 && pos.y >= 0 && pos.x < map_size.x && pos.y < map_size.y:
		height_map.lock()
		px = height_map.get_pixel(pos.x, pos.y)
		height_map.unlock()
	return px