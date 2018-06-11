extends MeshInstance

func _ready():
	# upscale, we can't subdivide by more then 100 in the property inspector
	mesh.size = Vector2(512.0, 512.0);
	mesh.subdivide_width = 256;
	mesh.subdivide_depth = 256;