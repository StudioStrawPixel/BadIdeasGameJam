extends Node2D

const BULLET = preload("uid://dp7fdpacyvlah")

@onready var muzzle: Marker2D = $Marker2D
@onready var shoot_timer: Timer = $ShootTimer

var can_shoot := true
var is_gun_equipped: bool = false

func _ready():
	shoot_timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1

	if Input.is_action_just_pressed("shoot") and can_shoot and is_gun_equipped:
		shoot()

func shoot():
	var bullet_instance = BULLET.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
	can_shoot = false
	shoot_timer.start()

func _on_timer_timeout():
	can_shoot = true
