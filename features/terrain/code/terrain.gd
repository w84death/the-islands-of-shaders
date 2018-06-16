extends MeshInstance

export var map_width = 2048.0;
export var map_height = 2048.0;
func _ready():
	# upscale, we can't subdivide by more then 100 in the property inspector
	mesh.size = Vector2(map_width, map_height);
	mesh.subdivide_width = map_width * 0.25;
	mesh.subdivide_depth = map_height * 0.25;