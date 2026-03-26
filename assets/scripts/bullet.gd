extends Area2D

const SPEED: int = 600

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var can_hit = true

func _ready():
	animated_sprite_2d.play()
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_animation_finished() -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
