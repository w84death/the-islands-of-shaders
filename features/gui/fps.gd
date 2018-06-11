extends Label

var fps = 0

func _ready():
	pass

func _process(delta):
	var current_fps = Performance.get_monitor(Performance.TIME_FPS)
	if current_fps > fps:
		fps += 1
	if current_fps < fps:
		fps -= 1
		 
	set_text(str(fps).pad_zeros(3) + " FPS")