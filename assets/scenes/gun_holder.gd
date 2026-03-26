extends Node2D

const BULLET = preload("uid://dp7fdpacyvlah")

@onready var gun_sprite: Sprite2D = $Gun
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer

var can_shoot := true
var is_gun_equipped := false
var original_scale: Vector2

func _ready():
	original_scale = gun_sprite.scale
	gun_sprite.visible = false
	shoot_timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if not is_gun_equipped:
		return

	look_at(get_global_mouse_position())
	gun_sprite.scale.y = -abs(original_scale.y) if rotation_degrees > 90 and rotation_degrees < 270 else abs(original_scale.y)

func shoot():
	if not can_shoot:
		return
	var bullet_instance = BULLET.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
	can_shoot = false
	shoot_timer.start()

func _on_timer_timeout():
	can_shoot = true

func equip():
	is_gun_equipped = true
	gun_sprite.visible = false
	await get_tree().create_timer(0.5).timeout  # wait for equip animation
	gun_sprite.visible = true

func unequip():
	is_gun_equipped = false
	gun_sprite.visible = false
