extends Control

##########################
const DIRECTORY = "user://"

var SAVE_DIR : String = DIRECTORY + "saves/"
var CONFIG_DIR : String = DIRECTORY + "confg/"
var config_path : String = CONFIG_DIR + "settings.dat"
var folder : String = ""

var data
var settings_data

var current_folder = ""
var current_path : String = "" 
var save_path = SAVE_DIR + current_folder + ".json"

var wallpaper_path

##########################
onready var toolbar = $Toolbar1
onready var wallpaper = $body/Wallpaper_rect

onready var menu_file = $Toolbar1/ARatio1/HBoxContainer/File
onready var menu_tab = $Toolbar1/ARatio1/HBoxContainer/Tab_menu
onready var menu_settings = $Toolbar1/ARatio1/HBoxContainer/Settings

onready var save_dialog = $Toolbar1/Front_Layers/SaveFileDialog
onready var load_dialog = $Toolbar1/Front_Layers/LoadFileDialog
onready var rename_dialog = $Toolbar1/Front_Layers/RenameDialog
onready var theme_dialog = $Toolbar1/Front_Layers/Theme_dialog
onready var wp_dialog = $Toolbar1/Front_Layers/WallpaperDialog

onready var bottom_label = $body/Bottom_panel/Label
onready var tab_container = $body/TabContainer
onready var blocker = $Toolbar1/Front_Layers/blocker
onready var discardtab = $Toolbar1/Toolbar_panel2/HBoxContainer/discard_tab

onready var progress_panel = $Toolbar1/progress_panel
onready var window_handl = $Toolbar1/Front_Layers/window_handler
onready var window_title = $Toolbar1/window_title

func _ready():
	call_deferred("_set_window")
	OS.set_window_title("Lunary : Empty")
	window_title.text = "Lunary : Empty"
	var date = OS.get_date()
	bottom_label.text = "%s:%s:%s - " % [date["day"],date["month"],date["year"]]
	
	menu_file.get_child(0).connect("id_pressed", self, "_file_id_pressed")
	save_dialog.connect("file_selected", self,"save_confirmed")
	load_dialog.connect("confirmed", self, "_load_confirmed")
	load_dialog.connect("file_selected", self, "_load_file_selected")
	rename_dialog.get_child(2).connect("pressed", self ,"_rename_confirmed")
	rename_dialog.get_child(3).connect("pressed", self ,"_rename_cancel")
	wp_dialog.connect("file_selected", self, "_load_image")
	
	menu_tab.get_child(0).connect("id_pressed", self, "_menu_tab_pressed")
	tab_container.connect("tab_selected", self, "change_current_tab")
	
	menu_settings.get_child(0).connect("id_pressed", self, "_menu_settings_pressed")
	theme_dialog.get_child(3).connect("pressed", self, "_apply_theme")
	theme_dialog.get_child(4).connect("pressed", self, "_cancel_theme")
	
	save_dialog.connect("hide", self, "blocker_hide")
	load_dialog.connect("hide", self, "blocker_hide")
	rename_dialog.connect("hide", self, "blocker_hide")
	theme_dialog.connect("hide", self, "blocker_hide")
	wp_dialog.connect("hide", self, "blocker_hide")
	
	
	window_handl.get_child(0).connect("pressed", self, "quit_program")
	window_handl.get_child(1).connect("pressed", self, "maximized_window")
	window_handl.get_child(2).connect("pressed", self, "minimized_window")
	
	discardtab.connect("pressed", self, "discard_current_tab")
	load_dialog.current_dir = "C:/Users/jerome/Desktop"
	save_dialog.current_dir = "C:/Users/jerome/Desktop"
# warning-ignore:return_value_discarded
	get_tree().connect("files_dropped", self, "on_files_dropped")
	var settings_config = File.new()
	
	if settings_config.file_exists(config_path):
		var error = settings_config.open(config_path, File.READ)
		if error == OK:
			load_settings_data()
	else:
		for node in get_tree().get_nodes_in_group("themed"):
			node.theme = Settings.default_theme

func _set_window():
	OS.min_window_size = Vector2(500,200)
	OS.max_window_size = Vector2(1536,824)
	OS.window_size = Vector2(1000,640)
	OS.window_position -= Vector2(500,100)

func load_settings_data():
	var settings_config = File.new()
	
	if settings_config.file_exists(config_path):
		var error = settings_config.open(config_path, File.READ)
		if error == OK:
			var datas = settings_config.get_var(true)
			settings_config.close()
			if Settings.debug_mode:
				print(datas)
			Settings.sav_on_load = datas["auto_save"]
			Settings.debug_mode = datas["debug_mode"]
			Settings.highlight_syntax = datas["highlight_syntax"]
			Settings.theme_color = datas["theme"]
			TabHandler.current_tabs = datas["files_loaded"]
			TabHandler.current_tabs_path = datas["files_path_loaded"]
			TabHandler.current_tabs_name = datas["file_names_loaded"]
			wallpaper_path = datas["wallpaper"]
			###########################################################
			replace_theme(datas["theme"]["window"], datas["theme"]["button"], datas["theme"]["h_button"],datas["theme"]["ledit"],datas["theme"]["f_ledit"],datas["theme"]["tab"],datas["theme"]["bg_tab"],datas["theme"]["bg"],datas["theme"]["fg"],datas["theme"]["menu"],datas["theme"]["sidebar"],datas["theme"]["h_menu"],datas["theme"]["dialog"],datas["theme"]["corner"])
			_apply_theme()
			if datas["wallpaper"] != null:
				_load_image(wallpaper_path)
			###########################################################
			if !Settings.sav_on_load:
				menu_settings.get_child(0).set_item_checked(1, false)
			if datas["highlight_syntax"] == true:
				if TabHandler.current_tabs != []:
					for i in tab_container.get_children():
						if !i.syntax_highlighting:
							i.syntax_highlighting = true
				menu_settings.get_child(0).set_item_checked(3, true)
			if datas["debug_mode"] == true:
				menu_settings.get_child(0).set_item_checked(2, true)
			if datas["auto_save"] == true:
					menu_settings.get_child(0).set_item_checked(1, true)
			if TabHandler.current_tabs != []:
				var file = File.new()
				for notes in TabHandler.current_tabs.size():
					if file.file_exists(TabHandler.current_tabs_path[notes]):
						var error_file = file.open(TabHandler.current_tabs_path[notes], File.READ)
						if error_file == OK:
							var tab_data = file.get_as_text()
							
							data = tab_data
							if Settings.debug_mode:
								print("loaded file successfuly!")
								print(notes)
							if datas["file_names_loaded"] != null:
								open_loaded_files(tab_data, datas["file_names_loaded"][notes], datas["file_texts_loaded"][notes])
								OS.set_window_title("Notepad : Loaded - " + datas["file_names_loaded"][notes])
								window_title.text = "Notepad : Loaded - " + datas["file_names_loaded"][notes]
							file.close()
							bottom_panel_text("Loaded file at :" + load_dialog.current_path)
							tab_container.current_tab = notes
						else:
							if Settings.debug_mode:
								print_debug("ERROR : Failed to load file!")
							return
					else:
						if Settings.debug_mode:
							print_debug("ERROR : File not exist! Skipping...")
						TabHandler.current_tabs_path.pop_at(notes)
						TabHandler.current_tabs.pop_at(notes)
						TabHandler.current_tabs_name.pop_at(notes)
			##########################################################
		else:
			print_debug("ERROR : File not recognized!")
			return
	else:
		print_debug("ERROR : File not found!")

func quit_program():
	blocker.show()
	_apply_theme()
	var indx = 0
	window_handl.get_child(0).release_focus()
	for i in TabHandler.current_tabs_path:
		indx += 1
		if i == "New file! Not saved!" && TabHandler.current_tabs != [] && Settings.sav_on_load:
			for b in tab_container.get_children():
				if b.get_index() == indx - 1:
					save_dialog.popup()
					tab_container.current_tab = indx - 1
					print(str(indx - 1))
			return
	var texts = []
	var config_directory = Directory.new()
	for current_texts in tab_container.get_children():
		texts.append(current_texts.text)
	if Settings.sav_on_load:
		settings_data = {
			"auto_save" : Settings.sav_on_load,
			"debug_mode" : Settings.debug_mode,
			"highlight_syntax" : Settings.highlight_syntax,
			"files_loaded" : TabHandler.current_tabs,
			"files_path_loaded" : TabHandler.current_tabs_path,
			"file_names_loaded" : TabHandler.current_tabs_name,
			"file_texts_loaded" : texts,
			"theme" : Settings.theme_color,
			"wallpaper" : wallpaper_path
		}
		print("saved")
	elif !Settings.sav_on_load:
		settings_data = {
			"auto_save" : Settings.sav_on_load,
			"debug_mode" : Settings.debug_mode,
			"highlight_syntax" : Settings.highlight_syntax,
			"files_loaded" : [],
			"files_path_loaded" : [],
			"file_names_loaded" : [],
			"file_texts_loaded" : [],
			"theme" : Settings.theme_color,
			"wallpaper" : wallpaper_path
		}
		print("not_saved")
	if !config_directory.dir_exists(CONFIG_DIR):
		config_directory.make_dir_recursive(CONFIG_DIR)
	var config_file = File.new()
	var error = config_file.open(config_path, File.WRITE)
	if error == OK:
		config_file.store_var(settings_data, true)
		config_file.close()
		if Settings.debug_mode:
			print("data : ", settings_data)
	yield(get_tree().create_timer(0.5),"timeout")
	get_tree().quit()

func maximized_window():
	var last_min_pos : Vector2
	window_handl.get_child(1).release_focus()
	if !Settings.maximize:
		Settings.maximize = true
		last_min_pos = rect_position
		OS.window_position = Vector2(0,0)
		OS.window_size.x = OS.get_screen_size().x
		OS.window_size.y = OS.get_screen_size().y - 40
		TabHandler.last_min_size = rect_size
	elif Settings.maximize:
		Settings.maximize = false
		OS.window_size = TabHandler.last_min_size
		OS.window_position = last_min_pos
	else:
		return

func minimized_window():
	window_handl.get_child(2).release_focus()
	OS.window_minimized = !OS.window_minimized

func blocker_hide():
	blocker.hide()

func _process(_delta):
	if save_dialog.visible:
		folder = str(save_dialog.current_file)
	if load_dialog.visible:
		current_path = "%s/%s" % [str(load_dialog.current_dir),str(load_dialog.current_file)]
	else:
		return

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("quick_save") && event is InputEventKey:
		quick_save()
		if Settings.debug_mode:
			print("Quick save action released")

func _file_id_pressed(id):
	match id:
		0:#Save file
			bottom_panel_text("Saving a File")
			save_dialog.call_deferred("grab_focus")
			save_dialog.popup()
			blocker.show()
		1:#Load file
			bottom_panel_text("Load a File")
			save_dialog.call_deferred("grab_focus")
			load_dialog.popup()
			_load_file_selected()
			blocker.show()
		2:#New File
			bottom_panel_text("Create a File")
			var new_tab = TextEdit.new()
			var tab_properties = {"theme" : Settings.default_theme, "name" : "New Note"}
			
			new_tab.theme = Settings.text_font
			new_tab.name = tab_properties["name"]
			new_tab.rect_size = tab_container.rect_size - Vector2(30,30)
			new_tab.highlight_current_line = true
			new_tab.show_line_numbers = true
			new_tab.wrap_enabled = true
			if Settings.highlight_syntax:
				new_tab.syntax_highlighting = true
			
			TabHandler.current_tabs_path.append("New file! Not saved!")
			TabHandler.current_tabs_name.append(new_tab.name)
			TabHandler.current_tabs.append(new_tab)
			tab_container.add_child(new_tab, true)
			tab_container.current_tab = TabHandler.current_tabs.size() - 1
			TabHandler.current_tab_selected = TabHandler.current_tabs.size() - 1
			rename_dialog.rect_position = OS.window_size * 0.4
			rename_dialog.get_child(1).call_deferred("grab_focus")
			if Settings.debug_mode:
				print("current tab : " + str(tab_container.current_tab) + str(new_tab.theme))
				
			
			return new_tab
		3:#Quick Sav
			quick_save()

func quick_save():
	var selected_file = 0
	if TabHandler.current_tabs != [] && TabHandler.current_tabs_path[tab_container.current_tab] != "New file! Not saved!":
		for tab in tab_container.get_children():
			if tab.get_index() == tab_container.current_tab:
				current_folder = tab.name
				for text in tab.get_children():
					data = tab.text
					selected_file = tab_container.current_tab
		progress_panel.show()
		progress_panel.get_node("lbl").text = "Saving in Progress..."
		if TabHandler.current_tabs_path != []:
			var file = File.new()
			var error = file.open(TabHandler.current_tabs_path[selected_file], File.WRITE)
			if error == OK:
				file.store_string(data)
				progress_panel.get_node("lbl").text = "Done!"
				file.close()
				bottom_panel_text("Quick Saved at : " + TabHandler.current_tabs_path[selected_file])
				progress_panel.hide()
				if Settings.debug_mode:
					print("quick saved at :" + TabHandler.current_tabs_path[selected_file])
			else:
				print("failed to save data")
	else:
		if TabHandler.current_tabs != []:
			save_dialog.show()
		elif Settings.debug_mode && TabHandler.current_tabs == []:
			print("ERROR : Nothing to quick save")
			return

func save_confirmed(path):
	if TabHandler.current_tabs != []:
		for tab in tab_container.get_children():
			if tab.get_index() == tab_container.current_tab:
				for i in TabHandler.current_tabs_path:
					if i == "New file! Not saved!":
						TabHandler.current_tabs_path.pop_at(tab_container.current_tab)
						TabHandler.current_tabs_path.insert(tab_container.current_tab, save_dialog.current_path)
						progress_panel.show()
						progress_panel.get_node("lbl").text = "Saving in Progress..."
				current_folder = tab.name
				for text in tab.get_children():
					data = tab.text
		
		var file = File.new()
		var error = file.open(str(path), File.WRITE)
		if error == ERR_FILE_EOF:
			progress_panel.hide()
			progress_panel.get_node("lbl").text = "Saving in Progress..."
		if error == OK:
			progress_panel.get_node("lbl").text = "Done!"
			file.store_string(data)
			file.close()
			if TabHandler.current_tabs != []:
				OS.set_window_title("Notepad - Loaded : %s" % [TabHandler.current_tabs_path[tab_container.current_tab]])
				progress_panel.hide()
			print(path)
			print("saved successfully!")
		else:
			print("Error : Cannot save this file!")
	else:
		print("Error : Nothing to save! silly...")
	save_dialog.hide()

func _load_confirmed():
	progress_panel.show()
	progress_panel.get_node("lbl").text = "Opening file..."
	var file = File.new()
	if file.file_exists(current_path):
		var error = file.open(current_path, File.READ)
		if error == OK:
			progress_panel.get_node("lbl").text = "Found File, Read Success!"
			print("loaded file successfuly!")
			var tab_data = file.get_as_text()
			progress_panel.hide()
			data = tab_data
			
			load_tab_data(tab_data, str(load_dialog.current_file.get_basename()))
			file.close()
			tab_container.current_tab = TabHandler.current_tabs.size() - 1
			bottom_panel_text("Loaded file at :" + load_dialog.current_path)
		else:
			print("ERROR : Failed to load file!")
			return
			
	else:
		print("ERROR : path not found : " + current_path + current_folder)
		return

func load_tab_data(tab_data, get_name):
	var text_edit = TextEdit.new()
	if Settings.highlight_syntax:
		text_edit.syntax_highlighting = true
	text_edit.theme = Settings.text_font
	text_edit.show_line_numbers = true
	text_edit.text = tab_data
	text_edit.name = get_name
	text_edit.wrap_enabled = true
	text_edit.highlight_current_line = true
	tab_container.add_child(text_edit)
	TabHandler.current_tabs_name.append(text_edit.name)
	TabHandler.current_tabs.append(text_edit)
	show_tabhandler_path()

func open_loaded_files(tab_data,names, text):
	var text_edit = TextEdit.new()
	if Settings.highlight_syntax:
		text_edit.syntax_highlighting = true
	text_edit.theme = Settings.text_font
	text_edit.show_line_numbers = true
	text_edit.text = tab_data
	text_edit.name = names
	text_edit.wrap_enabled = true
	text_edit.highlight_current_line = true
	text_edit.text = text
	tab_container.add_child(text_edit)

func _load_file_selected():
	if TabHandler.current_tabs == []:
		return
	else:
		for tab in tab_container.get_children():
				if tab.get_index() == tab_container.current_tab:
					current_folder = tab.name

func _rename_confirmed():
	rename_dialog.hide()
	bottom_panel_text("")
	if tab_container.current_tab == TabHandler.current_tab_selected && TabHandler.current_tabs != []:
		if rename_dialog.get_child(1).text != "":
			for i in tab_container.get_children():
				print("names found :" + i.name)
				if i.name ==  rename_dialog.get_child(1).text:
					tab_container.get_child(tab_container.current_tab).name = i.name + "(%s)" % [str(tab_container.current_tab + 1)]
					return
				else:
					tab_container.get_child(tab_container.current_tab).name = rename_dialog.get_child(1).text
					return
		else:
			bottom_panel_text("ERROR : Cant name a file with '' ")
			print("ERROR : Cant rename a file")
			return

func _rename_cancel():
	rename_dialog.hide()
	bottom_panel_text("")

func _menu_tab_pressed(id):
	match id:
		0:
			discard_current_tab()
		1:
			if TabHandler.current_tabs != []:
				for i in tab_container.get_children():
					i.queue_free()
				TabHandler.current_tabs = []
				TabHandler.current_tabs_name = []
				TabHandler.current_tabs_path = []
				OS.set_window_title("Lunary - Empty")
				window_title.text = "Lunary - Empty"
		2:
			if TabHandler.current_tabs != []:
				rename_dialog.show()
				rename_dialog.rect_position = OS.window_position * 0.5
				blocker.show()

func change_current_tab(id):
	OS.set_window_title("Lunary - Loaded : %s" % [TabHandler.current_tabs_path[id]])
	window_title.text = "Lunary - Loaded : %s" % [TabHandler.current_tabs_path[id]]
	TabHandler.current_tab_selected = id
	if Settings.debug_mode:
		print("selected tab: " + str(id))

func _menu_settings_pressed(id):
	match id:
		0:
			theme_dialog.popup()
			blocker.show()
		1:
			if menu_settings.get_child(0).is_item_checked(1):
				menu_settings.get_child(0).set_item_checked(1, false)
				Settings.sav_on_load = false
				if Settings.debug_mode:
					print("Setting ID : 1 : changed")
			else:
				menu_settings.get_child(0).set_item_checked(1, true)
				Settings.sav_on_load = true
				if Settings.debug_mode:
					print("Setting ID : 1 : changed")
		2:
			if menu_settings.get_child(0).is_item_checked(2):
				menu_settings.get_child(0).set_item_checked(2, false)
				Settings.debug_mode = false
			else:
				menu_settings.get_child(0).set_item_checked(2, true)
				Settings.debug_mode = true
		3:
			if menu_settings.get_child(0).is_item_checked(3):
				menu_settings.get_child(0).set_item_checked(3, false)
				if TabHandler.current_tabs != []:
					for i in tab_container.get_children():
						if i.syntax_highlighting:
							i.syntax_highlighting = false
					Settings.highlight_syntax = false
			elif !menu_settings.get_child(0).is_item_checked(3):
				menu_settings.get_child(0).set_item_checked(3, true)
				if TabHandler.current_tabs != []:
					for i in tab_container.get_children():
						if !i.syntax_highlighting:
							i.syntax_highlighting = true
					Settings.highlight_syntax = true

func selected_theme(id):
	match id:
		0:
			Settings.current_theme = id
		1:
			Settings.current_theme = id
		2:
			Settings.current_theme = id
		3:
			Settings.current_theme = id
		4:
			Settings.current_theme = id

func _apply_theme():
	for nodes in get_tree().get_nodes_in_group("themed"):
		nodes.theme = Settings.themes["Custom"]
	toolbar.apply_colors()
	Settings.theme_color = {
		"window" : toolbar.window_clr.color,
		"button" : toolbar.button_clr.color,
		"h_button" : toolbar.h_button_clr.color,
		"ledit" : toolbar.lineedit_clr.color,
		"f_ledit" : toolbar.f_ledit_clr.color,
		"tab" : toolbar.tab_clr.color,
		"bg_tab" : toolbar.bg_tab_clr.color,
		"bg" : toolbar.bg_clr.color,
		"fg" : toolbar.fg_clr.color,
		"sidebar" : toolbar.sidebar_clr.color,
		"menu" : toolbar.menu_clr.color,
		"h_menu" : toolbar.h_menu_clr.color,
		"dialog" : toolbar.dialog_clr.color,
		"corner" : toolbar.round_corner.value
	}
	yield(get_tree().create_timer(0.3),"timeout")
	theme_dialog.hide()

func replace_theme(window, button, h_button, ledit, f_ledit,tab,bg_tab,bg,fg,sidebar,menu,h_menu,dialog,corner):
	toolbar.window_clr.color = window
	toolbar.button_clr.color = button
	toolbar.h_button_clr.color = h_button
	toolbar.lineedit_clr.color = ledit
	toolbar.f_ledit_clr.color = f_ledit
	toolbar.tab_clr.color = tab
	toolbar.bg_tab_clr.color = bg_tab
	toolbar.bg_clr.color = bg
	toolbar.fg_clr.color = fg
	toolbar.sidebar_clr.color = sidebar
	toolbar.menu_clr.color = menu
	toolbar.h_menu_clr.color = h_menu
	toolbar.dialog_clr.color = dialog
	toolbar.round_corner.value = corner

func _cancel_theme():
	theme_dialog.hide()

func show_tabhandler_path():
	TabHandler.current_tabs_path.append(load_dialog.current_path)

func bottom_panel_text(add_text):
	var date = OS.get_date()
	bottom_label.text = "%s:%s:%s      - " % [date["day"],date["month"],date["year"]] + "Last Action : " + add_text

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_OUT:
			_process(false)
			for i in tab_container.get_children():
				i.release_focus()
			if Settings.debug_mode : print("out!")
		NOTIFICATION_WM_FOCUS_IN:
			_process(true)
			if Settings.debug_mode : print("entered")
		NOTIFICATION_THEME_CHANGED:
			print("theme changed!")

func on_files_dropped(path : PoolStringArray, _in_screen: int):
	for f in path.size():
		autoload(path[f])

func autoload(path):
	var file = File.new()
	if file.file_exists(path):
		var error = file.open(path, File.READ)
		if error == OK:
			print("loaded file successfuly!")
			var tab_data = file.get_as_text()
			
			data = tab_data
			
			open_dropped_files(tab_data, str(path.get_file().get_basename()), str(path))
			file.close()
			tab_container.current_tab = TabHandler.current_tabs.size() - 1
			bottom_panel_text("Loaded file at :" + load_dialog.current_path)
		else:
			print("ERROR : Failed to load file!")
			return
			
	else:
		print("ERROR : path not found : " + current_path + current_folder)
		return

func discard_current_tab():
	if TabHandler.current_tabs != []:
		if tab_container.current_tab == TabHandler.current_tab_selected:
			tab_container.get_child(tab_container.current_tab).queue_free()
			TabHandler.current_tabs.pop_at(tab_container.current_tab)
			TabHandler.current_tabs_name.pop_at(tab_container.current_tab)
			TabHandler.current_tabs_path.pop_at(tab_container.current_tab)

func open_dropped_files(tab_data, get_name, path: String):
	var text_edit = TextEdit.new()
	if Settings.highlight_syntax:
		text_edit.syntax_highlighting = true
	text_edit.theme = Settings.text_font
	text_edit.show_line_numbers = true
	text_edit.text = tab_data
	text_edit.wrap_enabled = true
	text_edit.highlight_current_line = true
	tab_container.add_child(text_edit)
	for i in tab_container.get_children():
		if i.name != text_edit.name:
			text_edit.name = get_name
			TabHandler.current_tabs_name.append(text_edit.name)
		else:
			text_edit.name = get_name + "(%s)" % [str(tab_container.current_tab + 1)]
			TabHandler.current_tabs_name.append(text_edit.name)
	TabHandler.current_tabs.append(text_edit)
	TabHandler.current_tabs_path.append(path)

func _load_image(path):
	var file = File.new()
	if file.file_exists(path):
		var error = file.open(path, File.READ)
		if error == OK:
			var img = Image.new()
			img.load(path)
			var texture = ImageTexture.new()
			texture.create_from_image(img, 0)
			
			wallpaper.texture = texture
			wallpaper_path = path
			
			file.close()
		else:
			print("ERROR : Failed to load file!")
			return
			
	else:
		print("ERROR : path not found : " + path)
		return

func _unload_image():
	wallpaper.texture = null
	wallpaper_path = ""
