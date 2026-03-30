extends Node2D

@onready var player: Node = $Player
@onready var bubble: Marker2D = $Player/bubble
@onready var monetbubble: Node = $Monkey/monetbubble2
@onready var monetcutscene: CollisionShape2D = $Monetcutscene/CollisionShape2D
@onready var monet: AnimatedSprite2D = $Monkey/Monet
@onready var smoke: GPUParticles2D = $Monkey/Smoke
@onready var tutorial: Control = $"CanvasLayer/Tutorial Window"
@onready var fade_layer: CanvasLayer = $Fade
@onready var music_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camera_limits: Node = $CameraLimits

var triggered := false
var monetflower_done := false

func _ready():
	if player and camera_limits:
		player.set_camera_limits(camera_limits)
	fade_layer.color_rect.color.a = 1.0
	var tween = fade_layer.fade(0.0, 1.5)
	tween.finished.connect(_start_scene)
	if not music_player.playing:
		music_player.play()

func _start_scene():
	player.set_process(true)
	player.set_physics_process(true)

func _on_monetcutscene_body_entered(body: Node2D) -> void:
	if body == player and not triggered:
		triggered = true
		monetcutscene.disabled = true
		start_monet_dialogue()

func start_monet_dialogue() -> void:
	var stored_velocity_y = player.velocity.y
	player.start_dialogue()
	player.animated_sprite.play("idle")
	var layout = Dialogic.start("meetmonet")
	add_child(layout)
	layout.register_character(load("res://Dialogue/monet.dch"), monetbubble)
	layout.register_character(load("res://Dialogue/glorb.dch"), bubble)
	await Dialogic.timeline_ended
	player.end_dialogue()
	player.velocity.y = stored_velocity_y
	player.gun_unlocked = true
	$Monetcutscene.queue_free()
	tutorial.show_tutorial("""
You can use your particle gun to change things around you
Equip using E
Shoot using LMB
Unequip using E again

*Note you cannot move while your gun is equipped
""")
	tutorial.tutorial_finished.connect(_on_tutorial_done)
	await wait_for_monetnobox_and_smoke()
	await get_tree().create_timer(0.5).timeout
	player.start_dialogue()
	Dialogic.start("monetflower")
	await Dialogic.timeline_ended
	player.end_dialogue()
	monetflower_done = true  
	player.can_play_footsteps = true

func wait_for_monetnobox_and_smoke() -> void:
	while monet.animation != "monetnobox" or (smoke and smoke.emitting):
		await get_tree().process_frame

func _on_tutorial_done():
	player.set_process(true)
	player.set_physics_process(true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if monetflower_done:
		await fade_layer.fade(0.0, 1.5).finished
		get_tree().change_scene_to_file("res://assets/scenes/levels/farquid.tscn")
	else:
		player.start_dialogue()
		Dialogic.start("monetno")
		await Dialogic.timeline_ended
		player.end_dialogue()
