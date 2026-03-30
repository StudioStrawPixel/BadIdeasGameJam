extends Control

@onready var options_screen: Panel = $OptionsScreen
@onready var start: Button = $StartGame
@onready var options: Button = $Options
@onready var exit: Button = $Exit
@onready var title: Label = $Title

func _ready():
	title.visible = true
	start.visible = true
	options.visible = true
	exit.visible = true
	options_screen.visible = false

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://opening_animation.tscn")


func _on_options_pressed() -> void:
	start.visible = false
	options.visible = false
	exit.visible = false
	options_screen.visible = true
	title.visible = false

func _on_back_pressed() -> void:
	_ready()

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_youtube_pressed() -> void:
	OS.shell_open("https://www.youtube.com/@StudioStrawPixel")
