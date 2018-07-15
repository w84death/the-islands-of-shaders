extends Spatial

var in_game = false


func _input(event):
	if Input.is_action_pressed("ui_accept") or event is InputEventMouseButton:
		show_game()
		in_game = true
	if Input.is_action_pressed("fullscreen"):
		toggle_fullscreen()
	if in_game && Input.is_action_pressed("quit"):
		show_menu()
		in_game = false
	elif Input.is_action_pressed("quit"):
		get_tree().quit()

func show_game():
		get_node("camera_rig/POV").make_current()
		get_node("GUI/intro").hide()
		get_node("GUI/demo").show()
		
func show_menu():
		get_node("logo/camera_menu").make_current()
		get_node("GUI/intro").show()
		get_node("GUI/demo").hide()

func toggle_fullscreen():
	OS.set_window_fullscreen(not OS.is_window_fullscreen())


func _on_sound_finished():
	pass # Replace with function body.
