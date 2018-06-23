extends Position3D

export var rotate_speed = 5.0;
export var move_speed = 5.0;
export var terrain_height = 45;
var angle_x = 0;
var angle_y = 0;

var _angle_x = -50;
var _angle_y = 0;

var height_map;
var move_to;

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
		move_to.y = get_height(pos).r * terrain_height
		transform.origin += (move_to - transform.origin) * delta * 10.0;
		
func get_height(pos):
	height_map.lock()
	var px = height_map.get_pixel(pos.x, pos.y)
	height_map.unlock()
	return px