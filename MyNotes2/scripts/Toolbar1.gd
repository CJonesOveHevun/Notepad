extends Control

var is_scrolling = true

onready var zoom_in = $Toolbar_panel2/HBoxContainer/Zoom_in
onready var zoom_out = $Toolbar_panel2/HBoxContainer/zoom_out
onready var zoom_label = $Toolbar_panel2/HBoxContainer/zoom_label
onready var search_bar = $Toolbar_panel2/HBoxContainer/search_bar
onready var unhide_button = $Toolbar_panel2/toolbar_panel/unhide_b
onready var hide_toolbar = $"%hide"
onready var button_wp = $"%wp_button"
onready var clear_wp_button = $"%clear_wp_button"

onready var window_clr = $"%window_clr"
onready var toolbar_clr = $"%toolbar_clr"
onready var button_clr = $"%button_clr"
onready var h_button_clr = $"%h_button_clr"
onready var lineedit_clr  = $"%lineedit_clr"
onready var f_ledit_clr = $"%f_ledit_clr"
onready var tab_clr = $"%tab_clr"
onready var bg_tab_clr = $"%bg_tab_clr"
onready var bg_clr = $"%bg_color"
onready var fg_clr = $"%fg_color"
onready var sidebar_clr = $"%sidebar_clr"
onready var menu_clr = $"%menu_color"
onready var h_menu_clr = $"%h_menu_clr"
onready var dialog_clr = $"%dialog_color"


onready var round_corner = $"%spinbox_corner"
onready var main = get_parent()

func _ready():
	hide_toolbar.connect("pressed", self, "hide_toolbar_on_pressed")
	unhide_button.connect("pressed", self, "hide_toolbar_on_pressed")
	zoom_in.connect("pressed", self, "zoom_in_action")
	zoom_out.connect("pressed", self, "zoom_out_action")
	search_bar.connect("text_entered", self, "search_words")
	button_wp.connect("pressed", self, "wp_show")
	clear_wp_button.connect("pressed", self, "clear_wp")
	print(OS.get_tablet_driver_name(0))
func _unhandled_key_input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("zoom_in"):
			zoom_in_action()
		if Input.is_action_just_pressed("zoom_out"):
			zoom_out_action()
		if Input.is_action_just_pressed("ctrl"):
			is_scrolling = false
		elif Input.is_action_just_released("ctrl"):
			is_scrolling = true
		else:
			return

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP && !is_scrolling:
				zoom_in_action()
			elif event.button_index == BUTTON_WHEEL_DOWN && !is_scrolling:
				zoom_out_action()

func zoom_in_action():
	if TabHandler.current_tabs != []:
		for i in main.tab_container.get_children():
			if i.get_index() == TabHandler.current_tab_selected:
				var tab_font = i.get_font(str(i.theme), "")
				i.add_font_override("font_override", tab_font)
				if tab_font.size < 90:
					tab_font.size += 5
					zoom_label.text = "Zoomed : %s~" % [tab_font.size]
		return

func zoom_out_action():
	if TabHandler.current_tabs != []:
		for i in main.tab_container.get_children():
			if i.get_index() == TabHandler.current_tab_selected:
				var tab_font = i.get_font(str(i.theme), "")
				i.add_font_override("font_override", tab_font)
				if tab_font.size > 15:
					tab_font.size -= 5
					zoom_label.text = "Zoomed : %s~" % [tab_font.size]
		return

func search_words(text):
	if TabHandler.current_tabs != []:
		for i in main.tab_container.get_children():
			if i.get_index() == TabHandler.current_tab_selected:
				for f in i.text:
					for e in text:
						if f == e:
							i.clear_colors()
							main.blocker.visible = true
							i.add_keyword_color(text, Color.yellow)
							search_bar.text = ""
							search_bar.release_focus()
							main.blocker.visible = false
							for b in i.get_line_count():
								var results = i.search(text, 0, b, 0)
								if results.size() > 0:
									var res_line = results[TextEdit.SEARCH_RESULT_LINE]
									var res_col = results[TextEdit.SEARCH_RESULT_COLUMN]
									i.select(res_line,res_col,res_line,res_col + text.length())
									

func apply_colors():
	new_color_tab(tab_clr.color, bg_tab_clr.color, round_corner.value)
	new_color_bg(bg_clr.color)
	new_color_button(button_clr.color,h_button_clr.color, round_corner.value)
	new_color_lineedit(lineedit_clr.color, f_ledit_clr.color, round_corner.value)
	new_color_window(window_clr.color)
	new_color_toolbar(toolbar_clr.color)
	new_color_fg(fg_clr.color)
	new_color_bottom(window_clr.color)
	new_color_menu(menu_clr.color, h_menu_clr.color, round_corner.value)
	new_dialog_color(dialog_clr.color, window_clr.color, round_corner.value)
	new_color_sidebar(sidebar_clr.color)

func new_color_toolbar(color):
	for nodes in get_tree().get_nodes_in_group("themed"):
		if nodes.name == "toolbar_panel":
			nodes.self_modulate = color

func new_color_window(color):
	node_name("window_panel", color)

func new_color_button(color,hovered_clr, corner):
	for nodes in get_tree().get_nodes_in_group("themed"):
		if nodes is Button:
			var new_c = StyleBoxFlat.new()
			var hover_c = StyleBoxFlat.new()
			new_c.set_bg_color(color)
			new_c.set_corner_radius_all(corner)
			hover_c.set_bg_color(hovered_clr)
			hover_c.set_corner_radius_all(corner)
			nodes.set('custom_styles/normal', new_c)
			nodes.set('custom_styles/hover', hover_c)
			nodes.set('custom_styles/focus', hover_c)
	node_name("File", hovered_clr)
	node_name("Tab_menu", hovered_clr)
	node_name("Settings", hovered_clr)

func new_color_lineedit(color, focus_clr, corner):
	for nodes in get_tree().get_nodes_in_group("themed"):
		if nodes is LineEdit:
			var new_c = StyleBoxFlat.new()
			var f_c = StyleBoxFlat.new()
			new_c.set_bg_color(color)
			new_c.set_corner_radius_all(corner)
			f_c.set_bg_color(focus_clr)
			f_c.set_corner_radius_all(corner)
			nodes.set('custom_styles/normal', new_c)
			nodes.set('custom_styles/focus', f_c)

func new_color_tab(color, bg_color , corner):
	for nodes in get_tree().get_nodes_in_group("themed"):
		if nodes is TabContainer:
			var new_c = StyleBoxFlat.new()
			var new_bg_c = StyleBoxFlat.new()
			new_c.set_bg_color(color)
			new_c.set_corner_radius_all(corner)
			new_c.content_margin_right = 10
			new_c.content_margin_left = 10
			new_c.content_margin_top = 5
			new_c.expand_margin_top = 5
			new_bg_c.set_bg_color(bg_color)
			new_bg_c.set_corner_radius_all(corner)
			new_bg_c.content_margin_right = 10
			new_bg_c.content_margin_left = 10
			new_bg_c.content_margin_top = 5
			new_bg_c.expand_margin_top = 5
			nodes.set('custom_styles/panel', new_c)
			nodes.set('custom_styles/tab_fg', new_c)
			nodes.set('custom_styles/tab_bg', new_bg_c)

func new_color_bottom(color):
	node_name("Bottom_panel", color)

func new_color_bg(color):
	node_name("bg_panel", color)

func new_color_fg(color):
	node_name("toolbar_panel", color)

func new_color_sidebar(color):
	node_name("sidebar", color)

func new_color_menu(color, h_color, corner):
	for nodes in get_tree().get_nodes_in_group("themed"):
		if nodes is MenuButton:
			var new_c = StyleBoxFlat.new()
			var new_c2 = StyleBoxFlat.new()
			new_c.set_bg_color(color)
			new_c.set_corner_radius_all(corner)
			new_c2.set_bg_color(h_color)
			new_c2.set_corner_radius_all(corner)
			nodes.get_child(0).set('custom_styles/panel', new_c)
			nodes.get_child(0).set('custom_styles/hover', new_c2)

func new_dialog_color(clr_panel, clr_window, corner):
	for nodes in get_tree().get_nodes_in_group("themed"):
		if nodes is WindowDialog:
			var new_c = StyleBoxFlat.new()
			new_c.set_bg_color(clr_panel)
			new_c.set_corner_radius_all(corner)
			new_c.border_width_top = 20
			new_c.expand_margin_top = 20
			new_c.border_color = clr_window
			nodes.set('custom_styles/panel', new_c)

func node_name(name : String, color : Color):
	for nodes in get_tree().get_nodes_in_group("themed"):
		if nodes.name == name:
			nodes.self_modulate = color

func wp_show():
	main.wp_dialog.show()
	main.theme_dialog.hide()

func clear_wp():
	main._unload_image()

func hide_toolbar_on_pressed():
	var panel = {0:$Toolbar_panel2/toolbar_panel,1:$Toolbar_panel2/HBoxContainer}
	var tween = get_tree().create_tween()
	if !panel[1].is_in_group("hidden"):
		unhide_button.release_focus()
		panel[1].add_to_group("hidden")
		hide_toolbar.release_focus()
		tween.tween_property(panel[0], "rect_position", Vector2(0,-80), 0.2).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(panel[1], "rect_position", Vector2(64,-80), 0.2).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(main.tab_container, "rect_position", Vector2(48,64), 0.2).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(unhide_button,"show")
		return
	panel[1].remove_from_group("hidden")
	unhide_button.release_focus()
	hide_toolbar.release_focus()
	tween.tween_property(panel[0], "rect_position", Vector2(0,40), 0.2).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(panel[1], "rect_position", Vector2(64,48), 0.2).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(main.tab_container, "rect_position", Vector2(48,88), 0.2).set_trans(Tween.TRANS_QUAD)
	unhide_button.hide()

func _on_rename_edit_text_entered(_new_text):
	main._rename_confirmed()
