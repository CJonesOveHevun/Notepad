extends Control

var following = false
var drag_pos = Vector2()
var dragged = false
var b_distance_to_edge

func _ready() -> void:
# warning-ignore:return_value_discarded
	connect("gui_input", self, "_on_Window_gui_input")
	b_distance_to_edge = OS.window_size.y - rect_global_position.y

func _input(event):
	if event is InputEventMouseMotion:
		if !following:
			return
		else:
			if !Settings.maximize:
				OS.set_window_position(OS.window_position + get_global_mouse_position() - drag_pos)
				OS.window_position.y = clamp(OS.window_position.y, -50, 974)
				OS.window_position.x = clamp(OS.window_position.x, -980, 1890)
			if Settings.maximize:
				OS.window_size = Vector2(1024, 600)
				OS.window_position = OS.get_screen_position() + get_local_mouse_position() + OS.window_position
				Settings.maximize = false
			if OS.window_position.y >= 981 - drag_pos.y:
				Input.warp_mouse_position(Vector2(get_local_mouse_position().x,drag_pos.y))
		
func _on_Window_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			drag_pos = get_local_mouse_position()
			TabHandler.last_min_size = rect_size
