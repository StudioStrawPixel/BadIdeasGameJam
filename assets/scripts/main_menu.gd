extends Control

@onready var options_screen: Panel = $OptionsScreen
@onready var start: Button = $StartGame
@onready var options: Button = $Options
@onready var exit: Button = $Exit
@onready var title: Label = $Title

var click_audio: AudioStreamPlayer2D

func _ready():
	title.visible = true
	start.visible = true
	options.visible = true
	exit.visible = true
	options_screen.visible = false

	click_audio = AudioStreamPlayer2D.new()
	click_audio.stream = load("res://assets/sounds/mouse.mp3")
	click_audio.pitch_scale = 1.3
	add_child(click_audio)

	start.pressed.connect(_on_start_game_pressed)
	options.pressed.connect(_on_options_pressed)
	exit.pressed.connect(_on_exit_pressed)
	if options_screen.has_node("Back"):
		options_screen.get_node("Back").pressed.connect(_on_back_pressed)
	if has_node("YouTubeButton"):
		get_node("YouTubeButton").pressed.connect(_on_youtube_pressed)

func _play_click() -> float:
	if click_audio:
		click_audio.play()
		return click_audio.stream.get_length() / click_audio.pitch_scale
	return 0.0

func _on_start_game_pressed() -> void:
	var wait_time = _play_click()
	await get_tree().create_timer(wait_time).timeout
	get_tree().change_scene_to_file("res://opening_animation.tscn")

func _on_options_pressed() -> void:
	_play_click()
	start.visible = false
	options.visible = false
	exit.visible = false
	options_screen.visible = true
	title.visible = false

func _on_back_pressed() -> void:
	_play_click()
	_ready()

func _on_exit_pressed() -> void:
	_play_click()
	get_tree().quit()

func _on_youtube_pressed() -> void:
	_play_click()
	OS.shell_open("https://www.youtube.com/@StudioStrawPixel")
