extends Sprite2D

const BULLET = preload("res://assets/scenes/bullet.tscn")

@onready var shoot_timer: Timer = $ShootTimer

var can_shoot := true
var original_scale: Vector2
var is_equipped := false

func _ready():
	original_scale = scale
	visible = false
	shoot_timer.timeout.connect(_on_timer_timeout)

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
	bullet_instance.global_position = global_position + Vector2(30 * sign(scale.x), 0)
	bullet_instance.rotation = global_rotation
	can_shoot = false
	shoot_timer.start()

func _on_timer_timeout():
	can_shoot = true

func equip():
	is_equipped = true
	

func unequip():
	is_equipped = false
	visible = false

func reveal(): 
	visible = true
