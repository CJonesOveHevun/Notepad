extends Control

var following = false
var drag_pos = Vector2()
var b_hand = false
var b_distance_to_edge

func _ready():
	b_distance_to_edge = OS.window_size.y - rect_global_position.y

func _process(_delta):
	if following:
		OS.set_window_position(OS.window_position + get_global_mouse_position() - drag_pos)
	
	if OS.window_position.y >= 1020:
		Input.warp_mouse_position(Vector2(get_local_mouse_position().x,get_local_mouse_position().y - 5))
		OS.window_position.y -= 10
	elif OS.window_position.x >= 1890:
		OS.window_position.x = 1890 - 5
	elif OS.window_position.x <= 0 - (0.9 * OS.window_size.x):
		OS.window_position.x = 0 + 5
	elif OS.window_position.y < -10 && Input.is_action_just_released("mb1"):
		OS.window_maximized = true


func _on_Window_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			drag_pos = get_local_mouse_position()
			if OS.window_maximized:
				OS.window_maximized = false;
				OS.set_window_position(OS.window_position - get_global_mouse_position())
		

