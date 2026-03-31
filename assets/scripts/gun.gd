extends Sprite2D

const BULLET = preload("res://assets/scenes/bullet.tscn")
const SHOOT_SOUND = preload("res://assets/sounds/transform.mp3")

@onready var shoot_timer: Timer = $ShootTimer
var can_shoot := false
var is_equipped := false
var original_scale: Vector2
var shoot_audio: AudioStreamPlayer2D

func _ready():
	original_scale = scale
	visible = false
	shoot_timer.timeout.connect(_on_timer_timeout)
	shoot_audio = AudioStreamPlayer2D.new()
	shoot_audio.stream = SHOOT_SOUND
	shoot_audio.pitch_scale = 1.3
	shoot_audio.volume_db = -5
	add_child(shoot_audio)

func _process(delta: float) -> void:
	if not is_equipped:
		return
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	rotation = direction.angle()
	if mouse_pos.x < global_position.x:
		scale.y = -abs(original_scale.y)
	else:
		scale.y = abs(original_scale.y)
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	var bullet_instance = BULLET.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = global_position + Vector2(1 * sign(scale.x), 0)
	bullet_instance.rotation = global_rotation
	can_shoot = false
	shoot_timer.start()
	if shoot_audio:
		shoot_audio.play()

func _on_timer_timeout():
	can_shoot = true

func equip():
	is_equipped = true
	visible = false
	can_shoot = false
	await get_tree().create_timer(0.5).timeout
	visible = true
	can_shoot = true

func unequip():
	is_equipped = false
	visible = false
	can_shoot = false

func reveal(): 
	visible = true
