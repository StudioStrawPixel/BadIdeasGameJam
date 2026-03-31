extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var bubble: Marker2D = $Player/bubble
@onready var mamabubble: Marker2D = $mama/mamabubble
@onready var bababubble: Marker2D = $baba/bababubble
@onready var flower_label: Label = $Player/FlowerLabel
@onready var fade: CanvasLayer = $Fade
@onready var camera_limits: Node2D = $CameraLimits
@onready var boxes: Node2D = $Boxes
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var trashnbox: Area2D = $tent
@onready var tire: Area2D = $drums

var trash_changed := false
var tire_changed := false

func _ready() -> void:
	player.can_play_footsteps = true
	player.gun_unlocked = true
	player.set_camera_limits(camera_limits)
	fade.fade(0.0, 1.5)
	audio_stream_player.play()

	trashnbox.area_entered.connect(_on_trash_hit)
	tire.area_entered.connect(_on_tire_hit)

func _on_trash_hit(area):
	if trash_changed:
		return
	if area.name == "Bullet":
		trash_changed = true
		$tent/Trashnbox.texture = load("res://assets/art/Background and Decor/tent.png")
		area.queue_free()

func _on_tire_hit(area):
	if tire_changed:
		return
	if area.name == "Bullet":
		tire_changed = true
		$drums/Tire.texture = load("res://assets/art/Background and Decor/drums.png")
		area.queue_free()
