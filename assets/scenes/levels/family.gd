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
@onready var mamas: Sprite2D = $mama/Mamas
@onready var trashnbox: Area2D = $tent
@onready var tire: Area2D = $drums
@onready var exit_area: Area2D = $exit


var trash_changed := false
var tire_changed := false
var cutscene_played := false
var family_dialogue_done := false
var helpfamily_started := false
var finale_done := false

func _ready() -> void:
	player.can_play_footsteps = true
	player.gun_unlocked = true
	player.set_camera_limits(camera_limits)
	fade.fade(0.0, 1.5)
	audio_stream_player.play()
	trashnbox.area_entered.connect(_on_trash_hit)
	tire.area_entered.connect(_on_tire_hit)
	exit_area.body_entered.connect(_on_exit_body_entered)

func _on_trash_hit(area):
	if not family_dialogue_done:
		return
	if trash_changed:
		return
	if area.name == "Bullet":
		trash_changed = true
		$tent/Trashnbox.texture = load("res://assets/art/Background and Decor/tent.png")
		area.queue_free()
		_check_start_helpfamily()

func _on_tire_hit(area):
	if not family_dialogue_done:
		return
	if tire_changed:
		return
	if area.name == "Bullet":
		tire_changed = true
		$drums/Tire.texture = load("res://assets/art/Background and Decor/drums.png")
		area.queue_free()
		_check_start_helpfamily()

func _on_cutscene_body_entered(body: Node2D) -> void:
	if body != player or cutscene_played:
		return
	cutscene_played = true
	await play_player_dialogue("meetfamily")
	family_dialogue_done = true

func _check_start_helpfamily():
	if helpfamily_started:
		return
	if trash_changed and tire_changed:
		helpfamily_started = true
		_start_helpfamily()

func _start_helpfamily():
	await get_tree().create_timer(1.0).timeout
	await play_player_dialogue("helpfamily")

	mamas.z_index = -3
	player.in_dialogue = true
	player.start_dialogue()
	player.animated_sprite.play("idle")

	var s = AudioStreamPlayer2D.new()
	s.stream = load("res://assets/sounds/drums.mp3")
	s.max_distance = 15000
	s.volume_db = -10
	add_child(s)
	s.play()

	await s.finished

	mamas.z_index = 0
	player.end_dialogue()
	player.in_dialogue = false

	await play_player_dialogue("finalfamily")
	finale_done = true

func play_player_dialogue(timeline_name: String):
	var stored_velocity_y = player.velocity.y
	player.start_dialogue()
	player.animated_sprite.play("idle")

	var layout = Dialogic.start(timeline_name)
	add_child(layout)

	layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
	layout.register_character(load("res://Dialogue/raccoonmama.dch"), mamabubble)
	layout.register_character(load("res://Dialogue/baba.dch"), bababubble)

	await Dialogic.timeline_ended
	player.end_dialogue()

func _on_exit_body_entered(body: Node2D) -> void:
	if body != player:
		return

	if family_dialogue_done and helpfamily_started and finale_done:
		get_tree().change_scene_to_file("res://finale.tscn")
	else:
		await play_player_dialogue("monetno")
