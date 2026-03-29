extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var waterfallcutscene: CollisionShape2D = $Area2D/waterfallcutscene
@onready var camera_limits: Node2D = $CameraLimits
@onready var fade_layer: CanvasLayer = $Fade
@onready var bubble: Marker2D = $Player/bubble
@onready var farquidbubble: Marker2D = $farquidcharacter/farquidbubble

var triggered := false
func _ready():
	if player and camera_limits:
		player.set_camera_limits(camera_limits)
	fade_layer.color_rect.color.a = 1.0
	var tween = fade_layer.fade(0.0, 1.5)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player and not triggered:
		triggered = true
		waterfallcutscene.disabled = true
		start_waterfall_dialogue()

func start_waterfall_dialogue() -> void:
	var stored_velocity_y = player.velocity.y
	player.start_dialogue()
	player.animated_sprite.play("idle")
	var layout = Dialogic.start("waterfall")
	add_child(layout)
	layout.register_character(load("res://Dialogue/farquid.dch"), farquidbubble)
	layout.register_character(load("res://Dialogue/unknown.dch"), farquidbubble)
	layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
	await Dialogic.timeline_ended
	player.end_dialogue()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	pass
