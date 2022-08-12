extends Control

var following = false
var drag_pos = Vector2()
var distance_to_edge
export (bool) var left = false
export (bool) var vertical = false

func _ready():
	OS.min_window_size = Vector2(300,200)
	OS.max_window_size = Vector2(1890, 1080)
	if vertical:
		distance_to_edge = OS.window_size.y - rect_global_position.y + 40
		rect_position.y = OS.window_size.y - distance_to_edge
	else:
		distance_to_edge = rect_global_position.x - OS.window_size.x + 40
		rect_position.x = OS.window_size.x - distance_to_edge


func _physics_process(_delta):
	var min_sizex = 300
	var max_sizex = 1890
	var min_sizey = 200
	var max_sizey = 1080
	if OS.window_maximized:
		visible = false;
	else:
		visible = true;
		
	if following:
		if vertical && OS.window_size.y > min_sizey:
			OS.window_size.y = get_global_mouse_position().y + distance_to_edge - drag_pos.y
			rect_position.y = OS.window_size.y - distance_to_edge
		elif not vertical && not left && OS.window_size.x > min_sizex:
			OS.window_size.x = get_global_mouse_position().x + distance_to_edge - drag_pos.x
			rect_position.x = OS.window_size.x - distance_to_edge
		else:
			pass
	if OS.window_size.y <= min_sizey:
		OS.window_size.y += min_sizey
		rect_position.y = OS.window_size.y - distance_to_edge
	if OS.window_size.x <= min_sizex:
		OS.window_size.x += min_sizex
		rect_position.x = OS.window_size.x - distance_to_edge
	if OS.window_size.y > max_sizex:
		OS.window_size.x += max_sizex
		rect_position.x = OS.window_size.x - distance_to_edge
	if OS.window_size.y > max_sizey:
		OS.window_size.y += max_sizey
		rect_position.y = OS.window_size.y - distance_to_edge



func _on_R_handler_gui_input(event):
	if event is InputEventMouseButton && OS.window_size >= Vector2(300,200):
		if event.get_button_index() == 1:
			following = !following
			drag_pos = get_local_mouse_position()

