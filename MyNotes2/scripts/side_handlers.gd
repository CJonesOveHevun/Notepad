extends Control

export(bool) var vertical
export(bool) var top
export(bool) var left
export(bool) var corner

var following : bool = false
var drag_pos = Vector2()
var distance_to_edge

var last_pos
var last_size

func _ready() -> void:
# warning-ignore:return_value_discarded
	self.connect("gui_input", self, "resize_input")
	if vertical:
		distance_to_edge = OS.window_size.y - rect_global_position.y
	else:
		distance_to_edge = rect_global_position.x - OS.window_size.x - 30
		#rect_position.x = OS.window_size.x - distance_to_edge - 74


func _input(event):
	if event is InputEventMouseMotion:
		if Settings.maximize:
			visible = false
		else:
			visible = true
		
		
		if !following:
			return
		else:
			if vertical && OS.min_window_size.y <= OS.window_size.y &&  OS.min_window_size.x <= OS.window_size.x:
				if !corner && !top && !left && get_global_mouse_position().y > OS.min_window_size.y:
					OS.window_size.y = get_global_mouse_position().y + distance_to_edge - drag_pos.y
				elif corner && !top && left && get_global_mouse_position().y > OS.min_window_size.y:
					OS.window_size.x = last_size.x + (last_pos.x - OS.window_position.x)
					if OS.min_window_size.y <= OS.window_size.y:
						OS.window_size.y = get_global_mouse_position().y + distance_to_edge - drag_pos.y
					else:
						OS.window_size.y = OS.min_window_size.y + 1
					if OS.min_window_size.x <= OS.window_size.x:
						OS.window_position.x = (OS.window_position + get_global_mouse_position() - drag_pos).x
					else:
						OS.window_size.x = OS.min_window_size.x + 1
					
				elif !left && !corner && top:
					OS.window_size.y = last_size.y + (last_pos.y - OS.window_position.y)
					if OS.min_window_size.y <= OS.window_size.y:
						OS.window_position.y = (OS.window_position + get_global_mouse_position() - drag_pos).y - 2
					else:
						OS.window_size.y = OS.min_window_size.y + 1
			
			
			elif !vertical && OS.min_window_size.x <= OS.window_size.x:
				if !left  && !corner && get_global_mouse_position().x > OS.min_window_size.x:
					OS.window_size.x = get_global_mouse_position().x + distance_to_edge - drag_pos.x + 45
				elif left && !corner:
					OS.window_size.x = last_size.x + (last_pos.x - OS.window_position.x)
					if OS.min_window_size.x <= OS.window_size.x:
						OS.window_position.x = (OS.window_position + get_global_mouse_position() - drag_pos).x
					else:
						OS.window_size.x = OS.min_window_size.x + 1
				elif !top && !left && corner:
					if get_global_mouse_position().y > OS.min_window_size.y:
						OS.window_size.y = get_global_mouse_position().y + distance_to_edge - drag_pos.y + 60
					if get_global_mouse_position().x > OS.min_window_size.x:
						OS.window_size.x = get_global_mouse_position().x + distance_to_edge - drag_pos.x + 80
			else:
				if !vertical && !top && !left && OS.min_window_size.x > OS.window_size.x:
					OS.window_size.x = OS.min_window_size.x + 1
				elif vertical && !left && !top && OS.min_window_size.y > OS.window_size.y:
					OS.window_size.y = OS.min_window_size.y + 1
			if OS.window_position.y >= 982:
				Input.warp_mouse_position(Vector2(OS.window_position.x, -10))

func resize_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			last_pos = OS.window_position
			last_size = OS.window_size
			drag_pos = get_local_mouse_position()
