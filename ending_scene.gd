extends Control

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var fade_layer: CanvasLayer = $Fade

@export var menu_scene_path: String = "res://assets/scenes/main_menu.tscn"

func _ready():
	fade_layer.color_rect.color.a = 1.0
	await fade_layer.fade(0.0, 1.5).finished
	
	video_player.play()
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	await fade_layer.fade(1.0, 1.5).finished
	get_tree().change_scene_to_file(menu_scene_path)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")
