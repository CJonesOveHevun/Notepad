extends Node

var sav_on_load : bool = true
var default_theme : Resource = load("res://themes/custom.tres")
var text_font : Resource = load("res://themes/text_font.tres")

var debug_mode : bool = false
var highlight_syntax : bool = false
var maximize : bool = false
var theme_color = {}


var themes = {"default" : default_theme,
 "Light": load("res://themes/light.tres"),
"Dark": load("res://themes/dark.tres"),
"Developer": load("res://themes/developer.tres"),
"Custom": load("res://themes/custom.tres")}

var current_theme : int = 0
