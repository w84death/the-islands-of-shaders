extends Spatial

export var in_game = false
export var is_intro = false

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		if is_intro and not in_game:
			show_menu()
		if not in_game and not is_intro or event is InputEventMouseButton:
			show_game()
		
	if Input.is_action_just_released("fullscreen"):
		toggle_fullscreen()
		
	if Input.is_action_pressed("quit"):
		if in_game:
			show_menu()
		if is_intro:
			get_tree().quit()
		else:
			show_intro()

func show_game():
		get_tree().change_scene('TIOS_game.tscn');
		
func show_menu():
		get_tree().change_scene('TIOS_menu.tscn');
		
func show_intro():
		get_tree().change_scene('TIOS_intro.tscn');

func toggle_fullscreen():
	OS.set_window_fullscreen(not OS.is_window_fullscreen())