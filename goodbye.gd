extends Node2D

@onready var fade: CanvasLayer = $Fade
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var closebox: Sprite2D = $Closebox

var new_closebox_texture := preload("res://assets/art/Background and Decor/openbox.png")

func _ready() -> void:
	await fade.fade(0.0, 1.5).finished
	animation_player.play("enter")
	await animation_player.animation_finished
	await get_tree().create_timer(0.5).timeout
	closebox.texture = new_closebox_texture
	await get_tree().create_timer(1.0).timeout
	_end_scene()

func _end_scene() -> void:
	await fade.fade(1.0, 3.0).finished
	get_tree().change_scene_to_file("res://ending_scene.tscn")
